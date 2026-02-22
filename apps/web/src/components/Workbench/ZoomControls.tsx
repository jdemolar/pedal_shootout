/**
 * Floating zoom controls for canvas views.
 * Shows +/- zoom buttons, a "Fit" button, and current zoom percentage.
 */

interface ZoomControlsProps {
  scale: number;
  onZoomIn: () => void;
  onZoomOut: () => void;
  onFitAll: () => void;
}

const ZoomControls = ({ scale, onZoomIn, onZoomOut, onFitAll }: ZoomControlsProps) => {
  const pct = Math.round(scale * 100);

  return (
    <div className="zoom-controls">
      <button
        className="zoom-controls__btn"
        onClick={onZoomOut}
        title="Zoom out"
        aria-label="Zoom out"
      >
        &minus;
      </button>
      <span className="zoom-controls__pct">{pct}%</span>
      <button
        className="zoom-controls__btn"
        onClick={onZoomIn}
        title="Zoom in"
        aria-label="Zoom in"
      >
        +
      </button>
      <button
        className="zoom-controls__btn zoom-controls__btn--fit"
        onClick={onFitAll}
        title="Fit all cards in view"
        aria-label="Fit all"
      >
        Fit
      </button>
    </div>
  );
};

export default ZoomControls;
