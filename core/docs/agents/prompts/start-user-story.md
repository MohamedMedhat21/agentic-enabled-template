# Start a user story

Work on the user story given with this request (an issue key or pasted story text) by following the **Working on a user story** section of [AGENTS.md](../../../AGENTS.md) exactly. That section is the source of truth; this prompt only adds how to start.

1. Read `AGENTS.md` in full, then the **Working on a user story** section again.
2. If the request contains an issue key, fetch the issue with the team's tracker tool. If no such tool is available, ask the user to paste the story, acceptance criteria and relevant comments.
3. Do the **Intake** phase and reply with:
   - a one-paragraph restatement of the story,
   - the acceptance criteria numbered `AC-1`, `AC-2`, ...,
   - every open question, asked in one batch.
4. Stop and wait for answers. Do not read the code in depth, write a plan, create a branch or change files before the acceptance criteria are confirmed.
5. Continue phase by phase. Stop at the plan approval gate, and never push.
6. If a question comes up in any later phase, including mid-implementation, stop the affected step, ask it, and wait for the answer. Record the question and answer in the plan.

If no story was given with the request, ask for the issue key or the story text and stop.
