"use client";

import * as React from "react";
import {
  Chat,
  ChatMessageSendEvent,
  Message,
} from "@progress/kendo-react-conversational-ui";
import { useState } from "react";
import {
  postProcessPresidioAnalysis,
  postProcessPresidioAnonymizer,
} from "./utils/post";
import { Splitter, SplitterOnChangeEvent } from "@progress/kendo-react-layout";
import ResumeManager from "./components/ResumeManager/ResumeManager";
import JobManager from "./components/JobManager/JobManager";

const user = {
  id: 1,
  avatarUrl:
    "https://demos.telerik.com/kendo-ui/content/web/Customers/RICSU.jpg",
  avatarAltText: "KendoReact Conversational UI RICSU",
};

const bot = { id: 0 };

const initialMessages: Message[] = [
  {
    author: bot,
    suggestedActions: [
      {
        type: "reply",
        value: "Neat!",
      },
    ],
    timestamp: new Date(),
    text: "Hello, this is a demo bot. I don't do much, but I can count symbols!",
  },
];

const App = () => {
  const [panes, setPanes] = React.useState<Array<any>>([
    { size: "20%", min: "20px", collapsible: true },
    {},
    { size: "30%", min: "20px", collapsible: true },
  ]);

  const [nestedPanes, setNestedPanes] = React.useState<Array<any>>([
    { size: "40%" },
    {},
    { size: "30%", resizable: false },
  ]);

  const [messages, setMessages] = useState(initialMessages);
  const [botResponse, setBotResponse] = useState<Message>({
    author: { id: 0 },
  });

  const onChange = (event: SplitterOnChangeEvent) => {
    setPanes(event.newState);
  };

  const onNestedChange = (event: SplitterOnChangeEvent) => {
    setNestedPanes(event.newState);
  };

  const addNewMessage = (event: ChatMessageSendEvent) => {
    //let botResponse = Object.assign({}, event.message);
    setBotResponse(Object.assign({}, event.message));

    if (event.message.text) {
      //botResponse.text = countReplayLength(event.message.text);
      postProcessPresidioAnalysis(event.message.text)
        .then((analysis_res) =>
          postProcessPresidioAnonymizer(event.message.text, analysis_res).then(
            (anonymizer_res) =>
              setBotResponse((oldBotResponse) => ({
                ...oldBotResponse,
                text: anonymizer_res,
              }))
          )
        )
        .catch((error) => console.error(error));
    }

    setMessages([...messages, event.message]);
    setTimeout(() => {
      setMessages((oldMessages) => [...oldMessages, botResponse]);
    }, 1000);
  };

  const countReplayLength = (question: string) => {
    let length = question.length;
    let answer = question + " contains exactly " + length + " symbols.";
    return answer;
  };

  return (
    <div>
      <Splitter panes={panes} onChange={onChange}>
        <Splitter
          style={{ height: 650 }}
          panes={nestedPanes}
          orientation={"vertical"}
          onChange={onNestedChange}
        >
          <div className="pane-content">
            <h3 className="m-3">Job Postings Selector</h3>
            <JobManager />
          </div>
          <div className="pane-content">
            <h3 className="m-3">Resume Manager</h3>
            <ResumeManager />
          </div>
        </Splitter>
        <div className="pane-content">
          <h3 className="m-3">My Analyses</h3>
          <p>Resizable only.</p>
        </div>
        <div className="pane-content">
          <h3 className="m-3">Search With Natural Language</h3>
          <Chat
            user={user}
            messages={messages}
            onMessageSend={addNewMessage}
            placeholder={"Type a message..."}
            className="m-5"
          />
        </div>
      </Splitter>
    </div>
  );
};

export default App;
