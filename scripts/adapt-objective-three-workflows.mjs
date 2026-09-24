import fs from 'node:fs'
import path from 'node:path'

const root = path.resolve(new URL('..', import.meta.url).pathname)
const workflowPath = path.join(root, 'workflows/n8n/Flow-ADH-01_MedirAdherencia.json')
const workflow = JSON.parse(fs.readFileSync(workflowPath, 'utf8'))

const codeNode = workflow.nodes.find((node) => node.name === 'CODE_ComputeAdherence')
if (!codeNode) throw new Error('No se encontró CODE_ComputeAdherence')

codeNode.parameters.jsCode = String.raw`const readings = $input.all()
  .map(item => item.json)
  .filter(r => r && r.measured_at && r.patient_id);

const ctx = $('SET_ADH_Context').first().json;
const latest = $('Get Latest Reading').first()?.json ?? {};

const patientId = String(ctx.patient_id);
const periodEndDate = String(ctx.period_end_date);
const timezone = String(ctx.timezone || 'America/Mexico_City');
const windowDaysList = [7, 14, 30];
const abandonmentThresholdDays = Number(ctx.abandonment_threshold_days || 7);
const workflowRunId = $('Create ADH Workflow Run').first().json.id;

function localDateFromIso(iso, tz) {
  if (!iso) return null;
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return null;

  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone: tz,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).formatToParts(d);

  const map = {};
  for (const p of parts) {
    if (p.type !== 'literal') map[p.type] = p.value;
  }
  return map.year + '-' + map.month + '-' + map.day;
}

function localHourFromIso(iso, tz) {
  const formatted = new Intl.DateTimeFormat('en-US', {
    timeZone: tz,
    hour: '2-digit',
    hour12: false,
  }).format(new Date(iso));
  const hour = Number(formatted);
  return hour === 24 ? 0 : hour;
}

function parseDateOnly(dateStr) {
  const [y, m, d] = String(dateStr).split('-').map(Number);
  return new Date(Date.UTC(y, m - 1, d));
}

function formatDateOnly(dateObj) {
  return dateObj.toISOString().slice(0, 10);
}

function addDays(dateObj, days) {
  const d = new Date(dateObj.getTime());
  d.setUTCDate(d.getUTCDate() + days);
  return d;
}

function diffDays(dateA, dateB) {
  return Math.round((dateA.getTime() - dateB.getTime()) / 86400000);
}

function roundTo(value, decimals) {
  const factor = 10 ** decimals;
  return Math.round(value * factor) / factor;
}

function buildWindowDates(startDateStr, endDateStr) {
  const start = parseDateOnly(startDateStr);
  const end = parseDateOnly(endDateStr);
  const dates = [];
  let cursor = new Date(start.getTime());

  while (cursor.getTime() <= end.getTime()) {
    dates.push(formatDateOnly(cursor));
    cursor = addDays(cursor, 1);
  }
  return dates;
}

function computeMaxRun(flags, targetValue) {
  let maxRun = 0;
  let current = 0;
  for (const f of flags) {
    if (f === targetValue) {
      current += 1;
      if (current > maxRun) maxRun = current;
    } else {
      current = 0;
    }
  }
  return maxRun;
}

function computeCurrentStreak(flags) {
  let streak = 0;
  for (let i = flags.length - 1; i >= 0; i--) {
    if (flags[i] === 1) streak += 1;
    else break;
  }
  return streak;
}

function measurementSlot(reading, tz) {
  if (reading.measurement_context === 'fasting_morning') return 'morning';
  if (reading.measurement_context === 'bedtime') return 'night';
  const hour = localHourFromIso(reading.measured_at, tz);
  if (hour < 12) return 'morning';
  if (hour < 18) return 'afternoon';
  return 'night';
}

// La tabla glucose_readings ya garantiza event_id único.
// Aun así, deduplicamos defensivamente antes de calcular.
const dedup = new Map();

for (const r of readings) {
  if (String(r.patient_id) !== patientId) continue;

  const key = r.event_id || r.id;
  if (!key || dedup.has(key)) continue;

  const localDate = localDateFromIso(r.measured_at, timezone);
  if (!localDate || localDate > periodEndDate) continue;

  dedup.set(key, {
    ...r,
    local_date: localDate,
  });
}

const safeReadings = [...dedup.values()]
  .sort((a, b) => String(a.measured_at).localeCompare(String(b.measured_at)));

const slotsByDate = new Map();
for (const reading of safeReadings) {
  const slots = slotsByDate.get(reading.local_date) || new Set();
  slots.add(measurementSlot(reading, timezone));
  slotsByDate.set(reading.local_date, slots);
}

const periodEnd = parseDateOnly(periodEndDate);
const lastReadingAt = latest && latest.measured_at
  ? String(latest.measured_at)
  : (safeReadings.length ? String(safeReadings[safeReadings.length - 1].measured_at) : null);
const lastReadingDate = lastReadingAt ? localDateFromIso(lastReadingAt, timezone) : null;
let daysSinceLastReading = null;
let abandonedFlag = false;

if (lastReadingDate) {
  daysSinceLastReading = diffDays(periodEnd, parseDateOnly(lastReadingDate));
  abandonedFlag = daysSinceLastReading >= abandonmentThresholdDays;
}

const calculatedAt = new Date().toISOString();
const output = [];

for (const windowDays of windowDaysList) {
  const windowStart = formatDateOnly(addDays(periodEnd, -(windowDays - 1)));
  const windowReadings = safeReadings.filter(
    r => r.local_date >= windowStart && r.local_date <= periodEndDate
  );
  const activeDateSet = new Set(windowReadings.map(r => r.local_date));
  const windowDates = buildWindowDates(windowStart, periodEndDate);
  const flags = windowDates.map(d => activeDateSet.has(d) ? 1 : 0);
  const dailySlots = windowDates.map(day => {
    const slots = slotsByDate.get(day) || new Set();
    return {
      day,
      morning: slots.has('morning'),
      afternoon: slots.has('afternoon'),
      night: slots.has('night'),
      reading_count: windowReadings.filter(r => r.local_date === day).length,
      complete: slots.size === 3,
    };
  });
  const daysWithReading = activeDateSet.size;
  const totalReadings = windowReadings.length;
  const completeDays = dailySlots.filter(day => day.complete).length;
  const expectedReadings = windowDays * 3;

  output.push({
    json: {
      patient_id: patientId,
      period_end_date: periodEndDate,
      window_days: windowDays,
      days_with_reading: daysWithReading,
      total_readings: totalReadings,
      adherence_pct: roundTo((daysWithReading / windowDays) * 100, 1),
      readings_per_week: roundTo((totalReadings / windowDays) * 7, 2),
      max_streak_days: computeMaxRun(flags, 1),
      current_streak_days: computeCurrentStreak(flags),
      max_gap_days: computeMaxRun(flags, 0),
      last_reading_at: lastReadingAt,
      days_since_last_reading: daysSinceLastReading,
      abandoned_flag: abandonedFlag,
      retention_30_flag: windowDays === 30 ? daysWithReading > 0 : null,
      complete_days: completeDays,
      completeness_pct: roundTo((completeDays / windowDays) * 100, 1),
      expected_readings: expectedReadings,
      slot_coverage_pct: roundTo(Math.min((totalReadings / expectedReadings) * 100, 100), 1),
      daily_slots: dailySlots,
      workflow_run_id: workflowRunId,
      calculated_at: calculatedAt,
      causation_event_id: ctx.causation_event_id || null
    }
  });
}

return output;`

const summaryFields = {
  complete_days: "={{ $('Loop Summaries').item.json.complete_days }}",
  completeness_pct: "={{ $('Loop Summaries').item.json.completeness_pct }}",
  expected_readings: "={{ $('Loop Summaries').item.json.expected_readings }}",
  slot_coverage_pct: "={{ $('Loop Summaries').item.json.slot_coverage_pct }}",
  daily_slots: "={{ $('Loop Summaries').item.json.daily_slots }}",
}

for (const node of workflow.nodes.filter((item) => item.parameters?.tableId === 'adherence_summary')) {
  if (!node.parameters.fieldsUi) continue
  const fields = node.parameters.fieldsUi.fieldValues ?? []
  const existing = new Set(fields.map((field) => field.fieldId))
  for (const [fieldId, fieldValue] of Object.entries(summaryFields)) {
    if (!existing.has(fieldId)) fields.push({ fieldId, fieldValue })
  }
  node.parameters.fieldsUi.fieldValues = fields
}

for (const nodeName of ['Get Latest Reading', 'Get Recent Readings']) {
  const node = workflow.nodes.find((item) => item.name === nodeName)
  const conditions = node?.parameters?.filters?.conditions
  if (!conditions) continue
  for (const [keyName, keyValue] of [['quality_state', 'valid'], ['processing_state', 'persisted']]) {
    if (!conditions.some((condition) => condition.keyName === keyName)) {
      conditions.push({ keyName, condition: 'eq', keyValue })
    }
  }
}

const runNode = workflow.nodes.find((node) => node.name === 'Create ADH Workflow Run')
const versionField = runNode?.parameters?.fieldsUi?.fieldValues?.find((field) => field.fieldId === 'workflow_version')
if (versionField) versionField.fieldValue = '2.1.0'

fs.writeFileSync(workflowPath, JSON.stringify(workflow, null, 2) + '\n')
console.log('Actualizado Flow-ADH-01_MedirAdherencia a contrato 2.1.0')
