# Example: Pivot Scenario

**Initial Feature**: Comments System
**Pivoted To**: Q&A System with Accepted Answers
**Complexity**: Standard (25-35 minutes including pivot)
**Project Type**: Internal Tool
**Outcome**: Product Brief after successful pivot

---

## Session Transcript (Abbreviated)

### Initial Direction: Comments System

```
User: "use product discovery for adding comments to our documentation"

Claude: [Stage 0 - Initialization]
        Quick context: What type of project is this?
        A) Business/Product
        B) Internal tool
        C) Personal/Side
        D) Open source

User: B - Internal tool for our engineering team

Claude: I've analyzed this and it looks like Standard complexity.
        Does that sound right?

User: Yes

Claude: Time expectations: ~25-35 minutes total
        Ready to start?

User: Yes

---

Claude: [Stage 1 - Product Owner Discovery begins]

        I'm now acting as Product Owner. Let's explore this idea.

        Who would use comments on the documentation?

User: Our engineering team—about 50 developers. They use our internal docs
      to understand systems and APIs.

Claude: What problem are they experiencing that comments would solve?

User: When something in the docs is unclear or outdated, developers have
      no way to flag it or ask questions. They ping each other on Slack,
      which is noisy and doesn't help future readers.

Claude: Tell me more about what happens when docs are unclear.

User: Developer hits unclear section, gets stuck, posts in Slack "What does
      this mean?", someone answers, but that answer is lost. Next person has
      the same question.

Claude: How often does this happen?

User: Daily. We see 10-20 documentation questions in Slack per day.

Claude: What would the ideal experience look like?

User: I was thinking... they could leave a comment on the doc section asking
      the question. Others could reply. Future readers would see it.

Claude: Interesting. Let me probe deeper. What happens after someone asks
        in the comments?

User: Well... someone knowledgeable would answer, I guess?

Claude: How would knowledgeable people know to check comments?

User: Hmm. Maybe notifications? Or they'd check periodically?

Claude: How motivated are they to check and answer comments?

User: [Pauses] That's a good question. They're busy. They might not check
      regularly.

Claude: So there's a risk the comment goes unanswered?

User: Yeah, actually that could happen. Then it's just a graveyard of
      unanswered questions, which might be worse than nothing.

Claude: Let me ask differently: When someone answers a docs question in
        Slack today, who typically answers?

User: Usually the person who wrote that section of docs, or a subject
      matter expert. Sometimes our docs team if it's just a clarity issue.

Claude: And how do they get notified about questions?

User: They see it in the channel—they're already monitoring Slack.

Claude: So the real problem is that Q&A is happening in Slack where it's
        ephemeral and not discoverable. Is that accurate?

User: Yes, exactly. The knowledge gets lost.

Claude: What if, instead of free-form comments, developers could ask
        questions directly on the doc page, and subject matter experts
        were notified? More like Stack Overflow style?

User: [Thinking] Oh, that's interesting. So it's more structured?

Claude: Yes. Questions could be marked as answered. Experts could be
        @mentioned. Best answer could be highlighted. Future readers
        see Q&A right there.

User: That actually solves the discoverability problem better. And the
      notification system would ensure questions get answered.

Claude: It also gives you metrics—you can see which sections have the
        most questions, indicating where docs need improvement.

User: That's really valuable. We've been blind to which docs are confusing.

Claude: So the real need is: Capture questions on docs, ensure they get
        answered by experts, make answers discoverable to future readers,
        and provide visibility into documentation gaps. Does that capture it?

User: Yes! That's actually much better than a comments system. A Q&A
      system makes more sense.

---

[Checkpoint #4: Viability Recommendation - CRITICAL]

Claude: Based on our discovery, my recommendation: PIVOT

        Rationale:

        The initial direction (comments system) has significant flaws:
        - No guarantee comments get answered
        - Could become graveyard of unanswered questions
        - Lacks notification system for experts
        - Doesn't prioritize best answers
        - Limited discoverability

        A better approach emerged during discovery:
        **Q&A system with accepted answers** (inspired by Stack Overflow)
        - Questions posed directly on doc sections
        - Subject matter experts notified
        - Answers can be marked as "accepted"
        - Q&A visible to future readers
        - Analytics on which docs need improvement

        This better addresses the core problem:
        - Ensures questions get to right people (notifications)
        - Ensures answers are provided (notification system + accepted answer)
        - Makes knowledge discoverable (structured Q&A)
        - Provides doc quality metrics

        Key finding:
        The real problem is "ephemeral Slack Q&A loses knowledge" not
        "need free-form comments." Structured Q&A solves this better.

        What would you like to do?

        A) Proceed to Product Brief with new direction (Q&A system)
           → Continue discovery with Q&A approach

        B) Pivot back to comments system
           → Stick with original idea

        C) Stop and document learnings

        D) Continue exploring
           → Dig deeper on either approach

User: A - Let's proceed with the Q&A system. That's the right solution.

Claude: Great! I'll document this pivot and continue discovery with the
        Q&A system direction.

        [Pivot #1 recorded]
        - From: Comments system
        - To: Q&A system with accepted answers
        - Reason: Better ensures answers, discoverability, expert notification

        Let's continue exploring the Q&A system...

---

[Discovery continues with new direction...]

Claude: Tell me more about the Q&A workflow. When a developer has a question...

User: They'd click "Ask Question" on the doc section, write their question,
      and it would notify the doc owner or tagged experts.

Claude: How do you determine who the experts are?

User: Good question. Maybe based on who wrote the doc? Or we could have
      a list of experts per topic area?

Claude: What if the doc owner has left the company or changed teams?

User: Then we'd need a fallback—maybe notify the docs team, or have
      topic-based owners instead of person-based.

Claude: What about answer quality? How do you ensure good answers?

User: The person who asked the question could mark an answer as "accepted."
      That would highlight it for future readers.

Claude: What if multiple good answers exist?

User: We could have voting, like Stack Overflow. Accepted answer is
      highlighted, but other answers are visible too.

Claude: Should the docs team be able to mark answers as accepted?

User: Yes! Sometimes the asker doesn't come back. Docs team should be
      able to curate.

[... continued exploration of Q&A system features ...]

---

[Checkpoint #1: Problem Understanding - REVISED]

Claude: Let me check if I understand the problem correctly:

        WHO: 50 engineers using internal documentation

        WHAT: Documentation questions answered in Slack are ephemeral
              and not discoverable by future readers

        WHY: Knowledge is lost, same questions asked repeatedly,
             no visibility into doc quality gaps

        WHEN: Daily—10-20 questions per day

        WHERE: Currently Slack; should be on doc pages themselves

        HOW (current): Developer asks in Slack, expert answers if they see it,
                       answer lost to history

        Does this capture the core user need?

User: Yes, perfect.

---

[Checkpoint #2: Solution Visualization]

Claude: Here's the solution vision for the Q&A system:

        Vision: Stack Overflow-style Q&A integrated directly into
        documentation pages

        Key Features:

        1. **Ask Question on Doc Section**
           - "Ask Question" button on each doc page
           - Question tied to specific section
           - Question visible to all future readers

        2. **Expert Notification System**
           - Doc owner notified of new questions
           - Topic experts notified
           - Fallback to docs team if owner unavailable

        3. **Answer Submission & Voting**
           - Experts can answer questions
           - Community can vote on answers
           - Best answers rise to top

        4. **Accepted Answer Highlighting**
           - Asker can accept best answer
           - Docs team can accept if asker doesn't
           - Accepted answer prominently displayed

        5. **Q&A Discoverability**
           - Q&A visible on doc page
           - Future readers see previous questions
           - Search includes Q&A content

        6. **Documentation Quality Analytics**
           - Dashboard shows docs with most questions
           - Identifies sections needing improvement
           - Tracks answer rates and time-to-answer

        User Journey:
        - Before: Developer reads unclear doc section
        - During: Clicks "Ask Question," writes question, submits
        - System: Notifies doc owner and experts
        - Expert: Sees notification, answers question
        - After: Asker marks answer accepted, Q&A visible to future readers

        Delight Factors:
        - Knowledge preserved forever
        - Future readers benefit immediately
        - Experts directed to questions needing their help
        - Docs team sees where to improve docs

        Does this match your vision?

User: Yes! Much better than comments. This solves the real problem.

---

[Checkpoint #3: Validation]

Claude: For Internal tool project:

        **Organizational Value**:
        - Reduces duplicate questions (10-20/day currently)
        - Preserves institutional knowledge
        - Improves documentation quality over time
        - Reduces interruptions in Slack
        - Helps onboarding (new engineers see Q&A)

        **ROI Estimate**:
        - Time saved: 10-20 questions/day * 10 min/question = 100-200 min/day
        - That's 2-3 hours of engineering time saved daily
        - Knowledge reuse multiplies value over time

        **Adoption Considerations**:
        - Requires behavior change from Slack to docs
        - Need to incentivize answering questions
        - Expert notification critical for adoption
        - Docs team must curate and encourage usage

        **Organizational Fit**:
        - Aligns with documentation improvement initiative
        - Supports knowledge sharing culture
        - Reduces Slack noise (frequent complaint)

        Does this validation make sense?

User: Yes. The ROI is strong—2-3 hours daily adds up.

---

[Checkpoint #4: Viability Recommendation - CRITICAL (Second Time)]

Claude: Based on complete discovery of Q&A system approach,
        my recommendation: PROCEED

        Rationale:

        Strong organizational value with clear benefits:
        - Solves real problem (ephemeral knowledge in Slack)
        - Measurable ROI (2-3 hours/day saved, growing over time)
        - Enables continuous doc improvement (analytics)
        - Feasible implementation (proven pattern from Stack Overflow)

        Previous pivot justified:
        - Comments system had notification and curation flaws
        - Q&A system better ensures questions get answered
        - Structured format improves discoverability

        Key findings:
        - Problem validated: 10-20 questions/day is significant
        - Solution addresses root cause
        - Organizational buy-in expected (solves Slack noise issue)
        - Technical approach proven elsewhere

        What would you like to do?

        A) Proceed to Product Brief
        B) Pivot to different approach [1 pivot remaining]
        C) Stop and document learnings
        D) Continue exploring

User: A - Proceed. Q&A system is the right solution.

---

[File location choice, Product Brief creation, etc. - similar to other examples]

[Checkpoint #6: Product Brief Review & Stage 2 Choice]

Claude: I've created the Product Brief saved to:
        ./product-briefs/docs-qa-system.md

        Key sections:

        **User Problem**: Documentation questions in Slack are ephemeral,
        not discoverable, repeated daily (10-20 questions)

        **Solution Vision**: Stack Overflow-style Q&A system integrated
        into docs with expert notifications and accepted answers

        **Recommendation**: PROCEED after pivot from comments system

        **Discovery History**:
        - Initial Direction: Free-form comments system
        - Pivot #1: Changed to Q&A system with accepted answers
        - Reason: Comments lacked notification/curation, Q&A ensures answers
        - Final Direction: Stack Overflow-inspired Q&A with analytics

        What would you like to do next?

        A) Continue to user stories (Stage 2)
        B) Skip user stories
        C) Request modifications
        D) Pause

User: A - Let's create user stories

[Stage 2 proceeds normally...]
```

---

## Product Brief Excerpt: Discovery History Section

```markdown
### Discovery History

**Initial Direction**: Free-form comments system on documentation pages

Developer could leave comments on any doc section. Other developers could
reply. Intended to capture questions and answers in-line with docs.

**Pivot #1**: Changed to Q&A system with accepted answers
*Reason*: Comments system had critical flaws discovered during exploration:
- No guarantee comments would be answered (no notification system)
- Could become graveyard of unanswered questions
- No way to highlight best answers
- Limited discoverability for future readers

**Key Insight from Discovery**:
The real problem is "Slack Q&A is ephemeral and not discoverable," not
"need free-form comments." A structured Q&A system with expert notification
and accepted answers better ensures questions get answered and knowledge
is preserved.

**Final Direction**: Stack Overflow-inspired Q&A system

- Questions posed on specific doc sections
- Subject matter experts notified automatically
- Answers can be accepted by asker or docs team
- Voting system for answer quality
- Q&A visible to future readers
- Analytics dashboard for doc quality insights

**Impact of Pivot**:
Pivot resulted in stronger solution that better addresses core problem.
Discovery conversation revealed flaws in initial approach and uncovered
superior alternative. Time well spent.
```

---

## Key Takeaways

### Why the Pivot Happened

**Discovery revealed flaws in initial idea**:
- ❌ Comments might go unanswered (no notification)
- ❌ Could create "question graveyard"
- ❌ No way to highlight quality answers
- ❌ Passive system depending on people checking

**Better alternative emerged through exploration**:
- ✅ Q&A system ensures expert notification
- ✅ Accepted answers highlight best solution
- ✅ Structured format improves discoverability
- ✅ Analytics provide doc quality insights

### Product Owner Role in Pivot

**Socratic questioning uncovered issues**:
- "How would experts know to check comments?"
- "What if comments go unanswered?"
- "Who typically answers questions today?"

**Suggested better alternative**:
- "What if it was more Stack Overflow style?"
- Drew from proven patterns
- Helped user see superior solution

### Pivot Handling

**Pivot properly documented**:
- From/To clearly stated
- Reason explained
- Key insight captured
- Impact noted in Product Brief

**Discovery continued with new direction**:
- Didn't restart from scratch
- Built on existing problem understanding
- Explored new solution thoroughly
- Reached PROCEED recommendation

**Pivot counter tracked**:
- 1 pivot used
- 1 pivot remaining if needed
- No concerns at single pivot

### When Pivots Are Valuable

**Pivot is valuable when**:
- Initial direction has fatal flaws
- Better alternative emerges
- Core problem remains valid
- New direction better addresses problem

**Pivot is NOT appropriate when**:
- Just refining details
- User is unsure of direction (needs offline clarity)
- Problem itself is wrong (should STOP)

### Time Impact

**Original timeline**: 25-35 minutes
**With pivot**: ~32 minutes total
- Extra 5-7 minutes for pivot exploration
- Still within Standard complexity range
- Time well spent for better outcome

---

## Comparison: Comments vs Q&A

### Comments System (Initial)

**Pros**:
- Simple concept
- Low barrier to participation
- Familiar pattern

**Cons**:
- No notification system
- No guarantee of answers
- Hard to identify best answers
- Could become cluttered
- No analytics value

### Q&A System (After Pivot)

**Pros**:
- Expert notification ensures answers
- Accepted answer highlights solution
- Voting improves answer quality
- Structured and discoverable
- Analytics reveal doc gaps
- Proven pattern (Stack Overflow)

**Cons**:
- Slightly more complex
- Requires notification system
- Needs expert definition/tagging

**Pivot Decision: Clearly justified**

---

## Discovery Patterns That Enabled Pivot

### Pattern 1: Challenge Assumptions

```
User: "They could leave a comment."
PO: "How would experts know to check comments?"
→ Reveals flaw in passive notification
```

### Pattern 2: Follow Current Workflow

```
PO: "Who answers questions in Slack today?"
User: "Doc owners or subject matter experts"
PO: "How are they notified?"
→ Reveals need for active notification system
```

### Pattern 3: Explore Consequences

```
PO: "What happens if comments go unanswered?"
User: "That could create a graveyard of questions"
→ Reveals fatal flaw in approach
```

### Pattern 4: Suggest Alternatives (When Appropriate)

```
PO: "What if it was more like Stack Overflow with Q&A?"
User: "Oh, that's interesting..."
→ Introduces proven pattern as alternative
```

### Pattern 5: Validate Better Fit

```
PO: "Does Q&A better address discoverability and ensuring answers?"
User: "Yes, actually much better."
→ Confirms pivot improves solution
```

---

## Output Quality After Pivot

**Product Brief includes**:
- Clear documentation of pivot history
- Rationale for direction change
- Key insight that drove pivot
- Final direction fully explored

**User Stories** (if Stage 2 completed):
- Based on Q&A system, not comments
- Acceptance criteria for expert notification
- Stories for accepted answer workflow
- Analytics dashboard requirements

**Handoff to task-preparation**:
- Architect understands why Q&A over comments
- Context includes pivot reasoning
- Implementation focuses on proven pattern

---

## Lessons from This Example

### For Users

**Trust the discovery process**:
- Initial idea may not be the best solution
- Product Owner perspective can reveal better approaches
- Pivots lead to stronger solutions

**Be open to pivots**:
- Don't be attached to initial direction
- Focus on solving problem, not defending idea
- Better solution is the goal

### For Product Owners

**Challenge assumptions gently**:
- Socratic questions reveal flaws
- Don't shoot down ideas—explore consequences
- Help user discover better solution

**Suggest alternatives when appropriate**:
- Draw from proven patterns
- Offer alternatives after understanding problem
- Guide user to better solutions

**Document pivots thoroughly**:
- Capture reasoning for future reference
- Show evolution of thinking
- Justify final direction

---

*End of Pivot Scenario Example*
