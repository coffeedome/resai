import { Upload, UploadOnAddEvent } from "@progress/kendo-react-upload";
const ResumeManager = () => {
  // const handleUpload = (event: UploadOnAddEvent) => {
  //   const files = event.affectedFiles;
  //   files.forEach((file) => {
  //     const rawFile = file.getRawFile ? file.getRawFile() : null;
  //     if (rawFile) {
  //       const formData = new FormData();
  //       formData.append("file", rawFile);
  //       fetch(
  //         "https://hddjeu9pg7.execute-api.us-west-2.amazonaws.com/prod/resumes/upload",
  //         {
  //           method: "POST",
  //           mode: "no-cors",
  //           headers: {
  //             "Content-Type": "application/json",
  //             "Access-Control-Allow-Origin": "*",
  //           },
  //           body: formData,
  //         }
  //       )
  //         .then((response) => response.json())
  //         .then((data) => {
  //           console.log(`File Uploaded Successfully: ${data}`);
  //         })
  //         .catch((error) => console.error(`File upload failed: ${error}`));
  //     } else {
  //       console.error(`getRawFile() undefined for this file. ${file}`);
  //     }
  //   });
  // };

  const handleUpload = (event: UploadOnAddEvent) => {
    const files = event.affectedFiles;

    files.forEach((file) => {
      if (file.getRawFile) {
        const filePayload = {
          name: file.name,
          type: file.getRawFile().type,
        };

        fetch(
          "https://hddjeu9pg7.execute-api.us-west-2.amazonaws.com/prod/resumes/upload",
          {
            method: "POST",
            mode: "no-cors",
            headers: {
              "Content-Type": "application/json",
              "Access-Control-Allow-Origin": "*",
            },
            body: JSON.stringify(filePayload),
          }
        )
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
