export default function FileAudio({ file, downloadUrl }) {
  return (
    <figure className="file-audio">
      <audio controls preload="metadata" src={downloadUrl}>
        Your browser does not support audio playback.
      </audio>
      <figcaption>{file.original_name}</figcaption>
    </figure>
  );
}
