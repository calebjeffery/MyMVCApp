import FileImage from './FileImage';
import FileVideo from './FileVideo';
import FileAudio from './FileAudio';
import FilePdf from './FilePdf';
import FileDocument from './FileDocument';
import FileGeneric from './FileGeneric';
import { getFileCategory, FILE_CATEGORIES } from './fileTypeUtils';

const RENDERERS = {
  [FILE_CATEGORIES.IMAGE]: FileImage,
  [FILE_CATEGORIES.VIDEO]: FileVideo,
  [FILE_CATEGORIES.AUDIO]: FileAudio,
  [FILE_CATEGORIES.PDF]: FilePdf,
  [FILE_CATEGORIES.DOCUMENT]: FileDocument,
  [FILE_CATEGORIES.GENERIC]: FileGeneric,
};

export default function FileRenderer({ file, downloadUrl, className = '' }) {
  if (!file) {
    return <div className={`file-renderer file-renderer--empty ${className}`}>No file selected</div>;
  }

  const category = getFileCategory(file.mime_type);
  const Component = RENDERERS[category] || FileGeneric;

  return (
    <div className={`file-renderer file-renderer--${category} ${className}`} data-file-id={file.id}>
      <Component file={file} downloadUrl={downloadUrl} />
    </div>
  );
}
