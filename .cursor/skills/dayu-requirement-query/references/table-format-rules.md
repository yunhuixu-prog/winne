# Table Format Rules

## Fixed Column Order

Always output in this order:

`需求类型、事件来源、事件类型、*事件id、*事件名称、参数、参数名称、参数类型、参数值类型、参数口径、参数值、参数值名称、参数值口径、*统计口径、备注说明、事件分组、标签`

## Aggregation Rule

- Aggregate by `事件id`.
- In each event, expand to params.
- In each param, expand to values.

## Export Format

- Export xlsx + markdown, no html.
- xlsx supports two modes: `expanded` (default) and `merged`.
- In `merged` mode, xlsx merges cells for event-level/param-level repeated values.
- xlsx detail header starts at row 1, and detail data starts at row 2.
- Markdown table uses the fixed detail column order above.
