import { formatFileSize } from './fileTypeUtils';

export default function FileGeneric({ file, downloadUrl }) {
  return (
    <div className="file-generic">
      <div className="file-generic__icon" aria-hidden="true">📎</div>
      <div className="file-generic__meta">
        <a href={downloadUrl} download={file.original_name}>
          {file.original_name}
        </a>
        <span className="file-generic__size">{formatFileSize(file.size)}</span>
        <span className="file-generic__provider">Stored via {file.storage_provider}</span>
      </div>
    </div>
  );
}
