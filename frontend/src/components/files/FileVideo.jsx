export default function FileVideo({ file, downloadUrl }) {
  return (
    <figure className="file-video">
      <video controls preload="metadata" src={downloadUrl}>
        Your browser does not support video playback.
      </video>
      <figcaption>{file.original_name}</figcaption>
    </figure>
  );
}
