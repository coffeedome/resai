import type { Metadata } from "next";
import "./styles/globals.scss";
import CustomAppBar from "./components/custom_app_bar";

export const metadata: Metadata = {
  title: "Resai",
  description: "Responsible AI Demo App",
  authors: [{ name: "Esteban Escobar", url: "https://estebanesco.bar" }],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <CustomAppBar />
        {children}
      </body>
    </html>
  );
}
