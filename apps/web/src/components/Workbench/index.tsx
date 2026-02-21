import { useState } from 'react';
import { useWorkbench } from '../../context/WorkbenchContext';
import WorkbenchTableView, { useWorkbenchProducts, WorkbenchRow } from './WorkbenchTable';
import DetailPanel from './DetailPanel';
import InsightsSidebar from './InsightsSidebar';
import ViewNav, { ViewMode } from './ViewNav';
import LayoutView from './LayoutView';
import PowerView from './PowerView';
import './index.scss';

const Workbench = () => {
  const {
    workbenches,
    activeWorkbench,
    createWorkbench,
    renameWorkbench,
    deleteWorkbench,
    setActiveWorkbench,
  } = useWorkbench();

  const { rows, loading, error } = useWorkbenchProducts();

  const [activeView, setActiveView] = useState<ViewMode>('list');
  const [isRenaming, setIsRenaming] = useState(false);
  const [renameValue, setRenameValue] = useState('');
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [showCreate, setShowCreate] = useState(false);
  const [createValue, setCreateValue] = useState('');
  const [selectedRow, setSelectedRow] = useState<WorkbenchRow | null>(null);

  const handleStartRename = () => {
    setRenameValue(activeWorkbench.name);
    setIsRenaming(true);
  };

  const handleConfirmRename = () => {
    const trimmed = renameValue.trim();
    if (trimmed && trimmed !== activeWorkbench.name) {
      renameWorkbench(activeWorkbench.id, trimmed);
    }
    setIsRenaming(false);
  };

  const handleRenameKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') handleConfirmRename();
    if (e.key === 'Escape') setIsRenaming(false);
  };

  const handleStartCreate = () => {
    setCreateValue('');
    setShowCreate(true);
  };

  const handleConfirmCreate = () => {
    const trimmed = createValue.trim();
    if (trimmed) {
      createWorkbench(trimmed);
    }
    setShowCreate(false);
  };

  const handleCreateKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') handleConfirmCreate();
    if (e.key === 'Escape') setShowCreate(false);
  };

  const handleDelete = () => {
    deleteWorkbench(activeWorkbench.id);
    setShowDeleteConfirm(false);
  };

  const handleRowClick = (row: WorkbenchRow) => {
    setSelectedRow(prev => prev?.id === row.id ? null : row);
  };

  const renderActiveView = () => {
    switch (activeView) {
      case 'list':
        return (
          <>
            <div className="workbench__content">
              <WorkbenchTableView
                rows={rows}
                loading={loading}
                error={error}
                onRowClick={handleRowClick}
              />
            </div>

            {!loading && rows.length > 0 && (
              <InsightsSidebar rows={rows} />
            )}

            {selectedRow && (
              <DetailPanel
                row={selectedRow}
                onClose={() => setSelectedRow(null)}
              />
            )}
          </>
        );

      case 'layout':
        return (
          <div className="workbench__content workbench__content--canvas">
            <LayoutView rows={rows} />
          </div>
        );

      case 'power':
        return (
          <div className="workbench__content workbench__content--canvas">
            <PowerView rows={rows} />
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="workbench">
      <div className="workbench__header">
        <div className="workbench__title-row">
          {isRenaming ? (
            <div className="workbench__rename">
              <input
                className="workbench__rename-input"
                value={renameValue}
                onChange={e => setRenameValue(e.target.value)}
                onKeyDown={handleRenameKeyDown}
                onBlur={handleConfirmRename}
                autoFocus
              />
            </div>
          ) : (
            <h1 className="workbench__title">{activeWorkbench.name}</h1>
          )}

          {workbenches.length > 1 && (
            <select
              className="workbench__selector"
              value={activeWorkbench.id}
              onChange={e => setActiveWorkbench(e.target.value)}
            >
              {workbenches.map(wb => (
                <option key={wb.id} value={wb.id}>{wb.name}</option>
              ))}
            </select>
          )}
        </div>

        <div className="workbench__actions">
          <button className="workbench__btn" onClick={handleStartCreate} title="New workbench">
            + New
          </button>
          <button className="workbench__btn" onClick={handleStartRename} title="Rename workbench">
            Rename
          </button>
          {showDeleteConfirm ? (
            <span className="workbench__delete-confirm">
              <span className="workbench__delete-prompt">Delete "{activeWorkbench.name}"?</span>
              <button className="workbench__btn workbench__btn--danger" onClick={handleDelete}>
                Yes
              </button>
              <button className="workbench__btn" onClick={() => setShowDeleteConfirm(false)}>
                No
              </button>
            </span>
          ) : (
            <button
              className="workbench__btn workbench__btn--danger"
              onClick={() => setShowDeleteConfirm(true)}
              title="Delete workbench"
            >
              Delete
            </button>
          )}
        </div>

        {showCreate && (
          <div className="workbench__create">
            <input
              className="workbench__create-input"
              value={createValue}
              onChange={e => setCreateValue(e.target.value)}
              onKeyDown={handleCreateKeyDown}
              placeholder="Workbench name..."
              autoFocus
            />
            <button className="workbench__btn" onClick={handleConfirmCreate}>Create</button>
            <button className="workbench__btn" onClick={() => setShowCreate(false)}>Cancel</button>
          </div>
        )}
      </div>

      <ViewNav activeView={activeView} onViewChange={setActiveView} />

      <div className="workbench__body">
        {renderActiveView()}
      </div>
    </div>
  );
};

export default Workbench;
