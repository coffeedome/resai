import {
  Upload,
  UploadFileInfo,
  UploadOnAddEvent,
} from "@progress/kendo-react-upload";
const ResumeManager = () => {
  const handleUpload = (event: UploadOnAddEvent) => {
    const files: UploadFileInfo[] = event.affectedFiles;

    files.forEach((file) => {
      if (file.name) {
        const filePayload = {
          name: file.name,
        };
        console.log(`Uploading ${file.name} of size ${file.size}`);

        fetch(process.env.ROOT_URL + "/resumes/upload", {
          method: "POST",
          mode: "no-cors",
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
          body: JSON.stringify(filePayload),
        })
          .then((response) => response.json())
          .then((data) => {
            console.log(`Presigned Url: ${data}`);
          })
          .catch((error) => console.error(`File upload failed: ${error}`));
      }
    });
  };

  return (
    <Upload
      batch={true}
      multiple={true}
      defaultFiles={[]}
      withCredentials={false}
      className="m-4"
      onAdd={handleUpload}
    />
  );
};

export default ResumeManager;
