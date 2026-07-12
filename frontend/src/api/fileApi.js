const API_BASE = import.meta.env.VITE_API_BASE || '/api';

async function request(path, options = {}) {
  const response = await fetch(`${API_BASE}${path}`, options);
  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new Error(body.error || `Request failed: ${response.status}`);
  }
  return response.json();
}

export async function listFiles() {
  return request('?action=list');
}

export async function getFileMetadata(id) {
  return request(`?action=file&id=${encodeURIComponent(id)}`);
}

export function getFileDownloadUrl(id) {
  return `${API_BASE}?action=file&id=${encodeURIComponent(id)}&download=1`;
}

export async function uploadFile(file, provider) {
  const formData = new FormData();
  formData.append('file', file);
  if (provider) {
    formData.append('provider', provider);
  }

  const response = await fetch(`${API_BASE}?action=upload`, {
    method: 'POST',
    body: formData,
  });

  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new Error(body.error || `Upload failed: ${response.status}`);
  }

  return response.json();
}

export async function deleteFile(id) {
  const response = await fetch(`${API_BASE}?action=file&id=${encodeURIComponent(id)}`, {
    method: 'DELETE',
  });

  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new Error(body.error || `Delete failed: ${response.status}`);
  }

  return response.json();
}
