export default function FileImage({ file, downloadUrl }) {
  return (
    <figure className="file-image">
      <img src={downloadUrl} alt={file.original_name} loading="lazy" />
      <figcaption>{file.original_name}</figcaption>
    </figure>
  );
}
