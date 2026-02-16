import { useWorkbench, ProductType } from '../../context/WorkbenchContext';
import './index.scss';

interface WorkbenchToggleProps {
  productId: number;
  productType: ProductType;
}

const WorkbenchToggle = ({ productId, productType }: WorkbenchToggleProps) => {
  const { addItem, removeItem, isInWorkbench } = useWorkbench();
  const active = isInWorkbench(productId);

  const handleClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (active) {
      removeItem(productId);
    } else {
      addItem(productId, productType);
    }
  };

  return (
    <button
      className={`workbench-toggle ${active ? 'workbench-toggle--active' : ''}`}
      onClick={handleClick}
      title={active ? 'Remove from workbench' : 'Add to workbench'}
      aria-label={active ? 'Remove from workbench' : 'Add to workbench'}
    >
      {active ? '\u2713' : '+'}
    </button>
  );
};

export default WorkbenchToggle;
