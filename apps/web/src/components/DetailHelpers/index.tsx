export function BooleanDetail({ label, value }: { label: string; value: boolean }) {
  return (
    <div className="data-table__detail">
      <div className="data-table__detail-label">{label}</div>
      <div className="data-table__detail-value">
        <span className={value ? 'bool-yes' : 'bool-no'}>{value ? 'Yes' : 'No'}</span>
      </div>
    </div>
  );
}

export function LinkDetail({ label, url }: { label: string; url: string | null }) {
  if (url == null) return null;
  return (
    <div className="data-table__detail">
      <div className="data-table__detail-label">{label}</div>
      <div className="data-table__detail-value">
        <a href={url} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">
          {url}
        </a>
      </div>
    </div>
  );
}
