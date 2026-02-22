import { useWorkbench } from '../../context/WorkbenchContext';
import { WorkbenchRow } from './WorkbenchTable';
import CanvasBase from './CanvasBase';
import ProductCard from './ProductCard';

const VIEW_KEY = 'layout';
const GRID_COLUMNS = 4;
const CARD_SPACING_X = 160;
const CARD_SPACING_Y = 84;
const GRID_OFFSET_X = 20;
const GRID_OFFSET_Y = 20;

/** Assign a default grid position for products without a saved position */
function defaultPosition(index: number): { x: number; y: number } {
  const col = index % GRID_COLUMNS;
  const row = Math.floor(index / GRID_COLUMNS);
  return {
    x: GRID_OFFSET_X + col * CARD_SPACING_X,
    y: GRID_OFFSET_Y + row * CARD_SPACING_Y,
  };
}

interface LayoutViewProps {
  rows: WorkbenchRow[];
}

const LayoutView = ({ rows }: LayoutViewProps) => {
  const { getViewPositions, updateViewPosition } = useWorkbench();
  const savedPositions = getViewPositions(VIEW_KEY);

  const getPosition = (instanceId: string, index: number) => {
    const saved = savedPositions[instanceId];
    if (saved) return saved;
    return defaultPosition(index);
  };

  const handleDragEnd = (instanceId: string, x: number, y: number) => {
    updateViewPosition(VIEW_KEY, instanceId, x, y);
  };

  if (rows.length === 0) {
    return (
      <div className="workbench__canvas-placeholder">
        Your workbench is empty. Add products from the catalog views.
      </div>
    );
  }

  return (
    <CanvasBase>
      {rows.map((row, index) => {
        const pos = getPosition(row.instanceId, index);
        return (
          <ProductCard
            key={row.instanceId}
            productType={row.product_type}
            manufacturer={row.manufacturer}
            model={row.model}
            x={pos.x}
            y={pos.y}
            onDragEnd={(x, y) => handleDragEnd(row.instanceId, x, y)}
          />
        );
      })}
    </CanvasBase>
  );
};

export default LayoutView;
