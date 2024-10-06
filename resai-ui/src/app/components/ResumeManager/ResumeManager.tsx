import { Upload, UploadOnAddEvent } from "@progress/kendo-react-upload";
const ResumeManager = () => {
  const handleUpload = (event: UploadOnAddEvent) => {
    const files = event.affectedFiles;
    files.forEach((file) => {
      const rawFile = file.getRawFile ? file.getRawFile() : null;
      if (rawFile) {
        const formData = new FormData();
        formData.append("file", rawFile);
        fetch(
          "https://d3mcwv9k17.execute-api.us-west-2.amazonaws.com/prod/resumes/upload",
          {
            method: "POST",
            mode: "no-cors",
            headers: {
              "Content-Type": "application/json",
              "Access-Control-Allow-Origin": "*",
            },
            body: formData,
          }
        )
          .then((response) => response.json())
          .then((data) => {
            console.log(`File Uploaded Successfully: ${data}`);
          })
          .catch((error) => console.error(`File upload failed: ${error}`));
      } else {
        console.error(`getRawFile() undefined for this file. ${file}`);
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
