export const FILE_CATEGORIES = {
  IMAGE: 'image',
  VIDEO: 'video',
  AUDIO: 'audio',
  PDF: 'pdf',
  DOCUMENT: 'document',
  GENERIC: 'generic',
};

export function getFileCategory(mimeType = '') {
  const mime = mimeType.toLowerCase();

  if (mime.startsWith('image/')) return FILE_CATEGORIES.IMAGE;
  if (mime.startsWith('video/')) return FILE_CATEGORIES.VIDEO;
  if (mime.startsWith('audio/')) return FILE_CATEGORIES.AUDIO;
  if (mime === 'application/pdf') return FILE_CATEGORIES.PDF;
  if (
    mime.startsWith('text/') ||
    mime.includes('word') ||
    mime.includes('document') ||
    mime.includes('spreadsheet') ||
    mime.includes('presentation')
  ) {
    return FILE_CATEGORIES.DOCUMENT;
  }

  return FILE_CATEGORIES.GENERIC;
}

export function formatFileSize(bytes) {
  if (bytes == null) return '';
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}
