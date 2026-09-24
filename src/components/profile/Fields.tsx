import type { InputHTMLAttributes, ReactNode, SelectHTMLAttributes } from 'react'

export function Field({ label, hint, error, id, ...props }: InputHTMLAttributes<HTMLInputElement> & { label: string; hint?: string; error?: string; id: string }) {
  return <div className="profile-field"><label htmlFor={id}>{label}{props.required && <span className="required-mark" aria-hidden="true"> *</span>}</label>
    {hint && <p id={`${id}-hint`} className="field-hint">{hint}</p>}
    <input {...props} id={id} aria-invalid={Boolean(error)} aria-describedby={[hint && `${id}-hint`, error && `${id}-error`].filter(Boolean).join(' ') || undefined} />
    {error && <p className="field-error" id={`${id}-error`}>{error}</p>}</div>
}

export function SelectField({ label, error, id, children, ...props }: SelectHTMLAttributes<HTMLSelectElement> & { label: string; error?: string; id: string; children: ReactNode }) {
  return <div className="profile-field"><label htmlFor={id}>{label}{props.required && <span className="required-mark" aria-hidden="true"> *</span>}</label>
    <select {...props} id={id} aria-invalid={Boolean(error)} aria-describedby={error ? `${id}-error` : undefined}>{children}</select>
    {error && <p className="field-error" id={`${id}-error`}>{error}</p>}</div>
}

export function Choices({ label, name, value, options, onChange, error }: { label: string; name: string; value: string; options: Array<[string, string]>; onChange: (value: string) => void; error?: string }) {
  return <fieldset className="choice-field" aria-describedby={error ? `${name}-error` : undefined}><legend>{label}</legend><div className="choice-grid">
    {options.map(([key, text]) => <label className={`choice-pill${value === key ? ' selected' : ''}`} key={key}><input type="radio" name={name} value={key} checked={value === key} onChange={() => onChange(key)} /><span>{text}</span></label>)}
  </div>{error && <p className="field-error" id={`${name}-error`}>{error}</p>}</fieldset>
}
