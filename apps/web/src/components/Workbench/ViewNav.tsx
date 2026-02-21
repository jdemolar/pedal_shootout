export type ViewMode = 'layout' | 'audio' | 'power' | 'midi' | 'control' | 'list';

interface ViewTab {
  key: ViewMode;
  label: string;
  enabled: boolean;
}

const VIEW_TABS: ViewTab[] = [
  { key: 'layout', label: 'Layout', enabled: true },
  { key: 'audio', label: 'Audio', enabled: false },
  { key: 'power', label: 'Power', enabled: true },
  { key: 'midi', label: 'MIDI', enabled: false },
  { key: 'control', label: 'Control', enabled: false },
  { key: 'list', label: 'List', enabled: true },
];

interface ViewNavProps {
  activeView: ViewMode;
  onViewChange: (view: ViewMode) => void;
}

const ViewNav = ({ activeView, onViewChange }: ViewNavProps) => {
  return (
    <div className="workbench__view-nav">
      {VIEW_TABS.map(tab => (
        <button
          key={tab.key}
          className={
            'workbench__view-tab' +
            (activeView === tab.key ? ' workbench__view-tab--active' : '') +
            (!tab.enabled ? ' workbench__view-tab--disabled' : '')
          }
          onClick={() => tab.enabled && onViewChange(tab.key)}
          title={tab.enabled ? undefined : 'Coming soon'}
          disabled={!tab.enabled}
        >
          {tab.label}
        </button>
      ))}
    </div>
  );
};

export default ViewNav;
