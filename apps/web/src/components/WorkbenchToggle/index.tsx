import { useWorkbench, ProductType } from '../../context/WorkbenchContext';
import './index.scss';

interface WorkbenchToggleProps {
  productId: number;
  productType: ProductType;
}

const WorkbenchToggle = ({ productId, productType }: WorkbenchToggleProps) => {
  const { addItem, removeItem, countInWorkbench, activeWorkbench } = useWorkbench();
  const count = countInWorkbench(productId);

  const handleAdd = (e: React.MouseEvent) => {
    e.stopPropagation();
    addItem(productId, productType);
  };

  const handleRemove = (e: React.MouseEvent) => {
    e.stopPropagation();
    // Remove the most recently added instance of this product
    const instances = activeWorkbench.items
      .filter(item => item.productId === productId)
      .sort((a, b) => b.addedAt.localeCompare(a.addedAt));
    if (instances.length > 0) {
      removeItem(instances[0].instanceId);
    }
  };

  return (
    <span className="workbench-toggle">
      {count > 0 && (
        <button
          className="workbench-toggle__btn workbench-toggle__btn--remove"
          onClick={handleRemove}
          title="Remove one from workbench"
          aria-label="Remove one from workbench"
        >
          &minus;
        </button>
      )}
      {count > 0 && (
        <span className="workbench-toggle__count">{count}</span>
      )}
      <button
        className="workbench-toggle__btn workbench-toggle__btn--add"
        onClick={handleAdd}
        title="Add to workbench"
        aria-label="Add to workbench"
      >
        +
      </button>
    </span>
  );
};

export default WorkbenchToggle;
