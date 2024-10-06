import { Upload } from "@progress/kendo-react-upload";
const ResumeManager = () => {
  return (
    <Upload
      batch={true}
      multiple={true}
      defaultFiles={[]}
      withCredentials={false}
      saveUrl={"https://demos.telerik.com/kendo-ui/service-v4/upload/save"}
      removeUrl={"https://demos.telerik.com/kendo-ui/service-v4/upload/remove"}
      className="m-4"
    />
  );
};

export default ResumeManager;
