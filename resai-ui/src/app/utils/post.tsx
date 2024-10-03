import { url } from "inspector";

async function postData(url = "", data = {}) {
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(data),
  });

  return response.json();
}

export async function postProcessPresidioAnalysis(inputText: string) {
  const analysis_url = process.env.PRESIDIO_ANALYZER_HOSTNAME;
  if (!analysis_url) {
    throw new Error("PRESIDIO_ANALYZER_HOSTNAME cannot be empty");
  }
  const analysis_port = process.env.PRESIDIO_ANALYZER_PORT;
  if (!analysis_port) {
    throw new Error("PRESIDIO_ANALYZER_PORT cannot be empty");
  }
  const analysis_endpoint = process.env.PRESIDIO_ANALYZER_ENDPOINT;
  if (!analysis_endpoint) {
    throw new Error("PRESIDIO_ANALYZER_ENDPOINT cannot be empty");
  }
  const data = {
    text: inputText,
    language: "en",
  };

  const analysis_res = await postData(
    `http://${analysis_url}:${analysis_port}/${analysis_endpoint}`,
    data
  );
  console.log(JSON.stringify(analysis_res));
  return analysis_res;
}

export async function postProcessPresidioAnonymizer(
  origInputText: string | undefined,
  analyzerResult: string
) {
  if (origInputText == undefined) {
    throw new Error("origInputText cannot be undefined");
  }

  const anonymizer_url = process.env.PRESIDIO_ANONYMIZER_HOSTNAME;
  if (!anonymizer_url) {
    throw new Error("PRESIDIO_ANONYMIZER_HOSTNAME cannot be empty");
  }
  const anonymizer_port = process.env.PRESIDIO_ANONYMIZER_PORT;
  if (!anonymizer_port) {
    throw new Error("PRESIDIO_ANONYMIZER_PORT cannot be empty");
  }
  const anonymizer_endpoint = process.env.PRESIDIO_ANONYMIZER_ENDPOINT;
  if (!anonymizer_endpoint) {
    throw new Error("PRESIDIO_ANONYMIZER_ENDPOINT cannot be empty");
  }

  const data = { text: origInputText, analyzer_results: analyzerResult };

  const anonymizer_res = await postData(
    `http://${anonymizer_url}:${anonymizer_port}/${anonymizer_endpoint}`,
    data
  );
  console.log(JSON.stringify(anonymizer_res));
  return anonymizer_res;
}
