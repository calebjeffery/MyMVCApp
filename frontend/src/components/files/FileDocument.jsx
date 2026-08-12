import { formatFileSize } from './fileTypeUtils';

export default function FileDocument({ file, downloadUrl }) {
  return (
    <div className="file-document">
      <div className="file-document__icon" aria-hidden="true">📄</div>
      <div className="file-document__meta">
        <a href={downloadUrl} target="_blank" rel="noopener noreferrer">
          {file.original_name}
        </a>
        <span className="file-document__size">{formatFileSize(file.size)}</span>
        <span className="file-document__mime">{file.mime_type}</span>
      </div>
    </div>
  );
}
