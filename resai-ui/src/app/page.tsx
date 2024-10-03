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
  const [messages, setMessages] = useState(initialMessages);
  const [botResponse, setBotResponse] = useState<Message>({
    author: { id: 0 },
  });

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
      <Chat
        user={user}
        messages={messages}
        onMessageSend={addNewMessage}
        placeholder={"Type a message..."}
        width={400}
      />
    </div>
  );
};

export default App;
