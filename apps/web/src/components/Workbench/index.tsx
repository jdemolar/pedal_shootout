import { useWorkbench } from '../../context/WorkbenchContext';

const Workbench = () => {
  const { activeWorkbench } = useWorkbench();

  return (
    <div style={{ padding: '24px 20px', color: '#c8c8c8', background: '#111', minHeight: '100vh', fontFamily: 'monospace' }}>
      <h1 style={{ color: '#f0f0f0', fontFamily: "'Helvetica Neue', sans-serif", fontSize: '24px', marginBottom: '16px' }}>
        {activeWorkbench.name}
      </h1>
      <p style={{ color: '#666', fontSize: '13px' }}>
        {activeWorkbench.items.length === 0
          ? 'Your workbench is empty. Add products from the catalog views.'
          : `${activeWorkbench.items.length} item${activeWorkbench.items.length === 1 ? '' : 's'} in workbench.`
        }
      </p>
    </div>
  );
};

export default Workbench;
