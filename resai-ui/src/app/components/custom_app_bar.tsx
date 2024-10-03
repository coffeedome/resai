import {
  AppBar,
  AppBarSection,
  AppBarSpacer,
  Avatar,
} from "@progress/kendo-react-layout";
import { Button } from "@progress/kendo-react-buttons";
import Link from "next/link";

export default function CustomAppBar() {
  return (
    <AppBar>
      <AppBarSection className="ms-3">
        <h1 className="title">Responsible AI Platform</h1>
      </AppBarSection>

      <AppBarSpacer />

      <AppBarSection>
        <div className="d-flex flex-row">
          <Button className="m-2">
            <Link
              href="/chatui"
              className="text-decoration-none text-black fs-3"
            >
              Chat Ui
            </Link>
          </Button>
          <Button className="m-2">
            <Link
              href="/admin"
              className="text-decoration-none text-black fs-3"
            >
              Admin Console
            </Link>
          </Button>
        </div>
      </AppBarSection>
    </AppBar>
  );
}
