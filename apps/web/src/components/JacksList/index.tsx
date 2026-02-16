import { Jack } from '../../utils/transformers';
import './index.scss';

interface JacksListProps {
  jacks: Jack[];
}

const CATEGORY_ORDER = ['audio', 'power', 'midi', 'expression', 'usb', 'aux'];

const CATEGORY_LABELS: Record<string, string> = {
  audio: 'Audio',
  power: 'Power',
  midi: 'MIDI',
  expression: 'Expression',
  usb: 'USB',
  aux: 'Aux',
};

const DIRECTION_LABELS: Record<string, string> = {
  input: 'Input',
  output: 'Output',
  bidirectional: 'Bidirectional',
};

function formatJackSummary(jack: Jack): string {
  const parts: string[] = [];

  if (jack.direction) {
    parts.push(DIRECTION_LABELS[jack.direction] ?? jack.direction);
  }

  if (jack.connector_type) {
    parts.push(jack.connector_type);
  }

  return parts.join(' · ');
}

function formatJackDetails(jack: Jack): string | null {
  const parts: string[] = [];

  if (jack.voltage) parts.push(jack.voltage);
  if (jack.current_ma != null) parts.push(`${jack.current_ma}mA`);
  if (jack.polarity) parts.push(jack.polarity);
  if (jack.impedance_ohms != null) parts.push(`${jack.impedance_ohms}Ω`);

  return parts.length > 0 ? parts.join(' · ') : null;
}

const JacksList = ({ jacks }: JacksListProps) => {
  if (jacks.length === 0) return null;

  const grouped = new Map<string, Jack[]>();
  for (const jack of jacks) {
    const cat = jack.category ?? 'other';
    if (!grouped.has(cat)) grouped.set(cat, []);
    grouped.get(cat)!.push(jack);
  }

  const sortedCategories = Array.from(grouped.keys()).sort((a, b) => {
    const ai = CATEGORY_ORDER.indexOf(a);
    const bi = CATEGORY_ORDER.indexOf(b);
    return (ai === -1 ? 999 : ai) - (bi === -1 ? 999 : bi);
  });

  return (
    <div className="jacks-list">
      <div className="jacks-list__header">Jacks</div>
      <div className="jacks-list__groups">
        {sortedCategories.map(category => (
          <div key={category} className="jacks-list__group">
            <div className="jacks-list__category">{CATEGORY_LABELS[category] ?? category}</div>
            {grouped.get(category)!.map(jack => {
              const summary = formatJackSummary(jack);
              const details = formatJackDetails(jack);
              return (
                <div key={jack.id} className="jacks-list__jack">
                  {jack.jack_name && (
                    <span className="jacks-list__jack-name">{jack.jack_name}</span>
                  )}
                  {summary && (
                    <span className="jacks-list__jack-summary">{summary}</span>
                  )}
                  {details && (
                    <span className="jacks-list__jack-details">{details}</span>
                  )}
                  {jack.function_desc && (
                    <span className="jacks-list__jack-function">{jack.function_desc}</span>
                  )}
                </div>
              );
            })}
          </div>
        ))}
      </div>
    </div>
  );
};

export default JacksList;
