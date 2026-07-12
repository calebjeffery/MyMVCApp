import { useCallback, useEffect, useState } from 'react';
import { FileRenderer } from './components/files';
import { deleteFile, getFileDownloadUrl, listFiles, uploadFile } from './api/fileApi';
import { formatFileSize } from './components/files/fileTypeUtils';

export default function App() {
  const [files, setFiles] = useState([]);
  const [selectedId, setSelectedId] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [uploading, setUploading] = useState(false);

  const loadFiles = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await listFiles();
      setFiles(result.files || []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadFiles();
  }, [loadFiles]);

  const selectedFile = files.find((f) => f.id === selectedId) || null;

  async function handleUpload(event) {
    const file = event.target.files?.[0];
    if (!file) return;

    setUploading(true);
    setError(null);
    try {
      const result = await uploadFile(file);
      await loadFiles();
      setSelectedId(result.file.id);
    } catch (err) {
      setError(err.message);
    } finally {
      setUploading(false);
      event.target.value = '';
    }
  }

  async function handleDelete(id) {
    setError(null);
    try {
      await deleteFile(id);
      if (selectedId === id) setSelectedId(null);
      await loadFiles();
    } catch (err) {
      setError(err.message);
    }
  }

  return (
    <div className="app">
      <header className="app__header">
        <h1>Documentation Platform</h1>
        <p>Files are stored on disk; location pointers live in the external storage table.</p>
      </header>

      <main className="app__layout">
        <aside className="app__sidebar">
          <label className="upload-button">
            {uploading ? 'Uploading…' : 'Upload file'}
            <input type="file" onChange={handleUpload} disabled={uploading} hidden />
          </label>

          {loading && <p>Loading files…</p>}
          {error && <p className="error">{error}</p>}

          <ul className="file-list">
            {files.map((file) => (
              <li key={file.id} className={file.id === selectedId ? 'is-selected' : ''}>
                <button type="button" onClick={() => setSelectedId(file.id)}>
                  <span className="file-list__name">{file.original_name}</span>
                  <span className="file-list__meta">
                    {formatFileSize(file.size)} · {file.storage_provider}
                  </span>
                </button>
                <button
                  type="button"
                  className="file-list__delete"
                  onClick={() => handleDelete(file.id)}
                  aria-label={`Delete ${file.original_name}`}
                >
                  ×
                </button>
              </li>
            ))}
          </ul>
        </aside>

        <section className="app__content">
          {selectedFile ? (
            <FileRenderer
              file={selectedFile}
              downloadUrl={getFileDownloadUrl(selectedFile.id)}
            />
          ) : (
            <div className="app__placeholder">Select a file to preview</div>
          )}
        </section>
      </main>
    </div>
  );
}
