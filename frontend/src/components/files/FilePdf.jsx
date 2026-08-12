export default function FilePdf({ file, downloadUrl }) {
  return (
    <figure className="file-pdf">
      <iframe
        title={file.original_name}
        src={downloadUrl}
        className="file-pdf__frame"
      />
      <figcaption>
        <a href={downloadUrl} target="_blank" rel="noopener noreferrer">
          {file.original_name}
        </a>
      </figcaption>
    </figure>
  );
}
