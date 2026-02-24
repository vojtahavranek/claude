# Example: Complex Feature Discovery

**Feature**: Payment Processing System
**Complexity**: Deep (40-55 minutes)
**Project Type**: Business/Product
**Outcome**: Product Brief + User Stories → Handoff to task-preparation

---

## Session Transcript (Abbreviated)

### Invocation

```
User: "use product discovery for payment processing integration"
```

### Stage 0: Initialization

```
Claude: Quick context: What type of project is this?
        A) Business/Product
        B) Internal tool
        C) Personal/Side project
        D) Open source

User: A - Business product with paying customers

Claude: I've analyzed "payment processing integration" and this looks
        like Deep complexity.

        Characteristics:
        - Complex system integration
        - Multiple user segments (customers, admins)
        - Significant business validation needed
        - Security and compliance considerations
        - Many unknowns to explore

        Does Deep complexity sound right?

        Quick (10-15 min) - Simple feature
        Standard (25-35 min) - Medium feature
        Deep (40-55 min) - Complex feature, thorough discovery

User: Yes, Deep is appropriate. This is critical for our business.

Claude: Time expectations for Deep complexity:

        Stage 1 (Product Owner Discovery): ~30-40 minutes
        - Comprehensive conversation covering all themes deeply
        - 6 approval checkpoints (4 critical, 2 lightweight)

        Stage 2 (User Stories - optional): ~15-20 minutes
        - Detailed user stories with acceptance criteria
        - 3 approval checkpoints

        Total: ~45-60 minutes with 9 approval points

        You can pause at any approval gate and resume later.
        Ready to start?

User: Yes, let's dive deep
```

### Stage 1: Product Owner Discovery (Abbreviated)

```
Claude: [Product Owner role loaded]
        [discovery-questions.md auto-loaded]

        I'm now acting as Product Owner to explore this idea deeply.

        Let's start with the users. Who needs payment processing?

User: Our customers who want to subscribe to our SaaS product. Right now
      we're manually invoicing which doesn't scale.

Claude: Tell me about these customers. What are their characteristics?

User: Mostly small business owners, 25-250 employees. Tech-savvy enough
      to use our software but not developers. Value convenience and trust.

Claude: What's the current payment experience like for them?

User: We send them a PDF invoice via email, they pay via bank transfer or
      check. Takes 5-15 days to receive payment. Lots of back-and-forth.

Claude: What problems does this create?

User: For customers: Friction, multiple steps, feels outdated, no instant
      access to service. For us: Cash flow issues, manual reconciliation,
      can't offer trials, looks unprofessional.

Claude: How often does this pain point occur?

User: Every single new signup and every monthly renewal. We're getting 20-30
      new signups per month now. The manual process is breaking down.

Claude: What's the impact of this problem?

User: We're losing customers at signup—maybe 40% abandon when they see the
      manual invoice process. Our competitor offers instant signup with card.
      Also, late payments hurt our cash flow.

[... deeper exploration of problem space continues ...]

Claude: Walk me through what the ideal payment experience would look like
        for a customer.

User: Customer clicks "Subscribe," enters their card info on a secure form,
      and boom—they're subscribed. They get instant access, we get instant
      payment. For monthly renewals, it should be automatic—they don't think
      about it.

Claude: What about edge cases? Failed payments? Refunds? Disputes?

User: Good point. Failed payments need automatic retry and notification.
      Refunds within 30 days for any reason. Disputes... we need visibility
      into that.

Claude: What payment methods do customers expect?

User: Credit/debit cards definitely. Some asked for ACH or bank transfers.
      A few international customers want PayPal. But cards are 90% of demand.

Claude: Tell me about security and compliance requirements.

User: We can't store card numbers—too risky. Need PCI compliance but don't
      want to manage that ourselves. GDPR compliance for EU customers. Must
      prevent fraud.

Claude: Who else besides customers interacts with payments?

User: Our admin team needs to see payment status, issue refunds, handle
      disputes. Our finance team needs reports for reconciliation and taxes.
      Customer support needs to see customer payment history.

[... thorough exploration of solution continues ...]

---

[Checkpoint #1: Problem Understanding]

Claude: Let me check if I understand the problem correctly:

        WHO:
        - Primary: Small business customers (25-250 employees)
        - Secondary: Internal admin, finance, support teams

        WHAT:
        - Customers: Manual invoice process creates friction, delays access
        - Business: Manual reconciliation, cash flow issues, customer loss

        WHY:
        - 40% signup abandonment (losing revenue)
        - 5-15 day payment delays (cash flow impact)
        - Manual process doesn't scale (20-30 signups/month growing)
        - Competitor advantage (instant signup)

        WHEN:
        - Every signup (20-30/month)
        - Every monthly renewal
        - Failed payment scenarios
        - Refund requests

        WHERE:
        - Customer: Signup flow and account management
        - Internal: Admin dashboard and finance reporting

        HOW (current):
        - PDF invoices emailed
        - Bank transfer or check payment
        - Manual reconciliation and follow-up
        - Insufficient for scale

        Does this capture the core user needs?

User: Yes, that's comprehensive. The 40% abandonment is killing us.

---

[Checkpoint #2: Solution Visualization]

Claude: Here's what I'm hearing for the solution:

        Vision: Automated payment processing system that enables instant
        subscription signup and automated recurring billing

        Key Features:

        1. **Secure Card Payment Form**
           - Hosted/embedded secure card entry
           - PCI-compliant (not storing cards ourselves)
           - Instant payment verification

        2. **Automated Recurring Billing**
           - Monthly automatic charges
           - Smart retry logic for failed payments
           - Customer notifications

        3. **Multi-Payment Method Support**
           - Credit/debit cards (primary)
           - ACH/bank transfers
           - PayPal (international)

        4. **Refund & Dispute Handling**
           - 30-day refund policy automation
           - Dispute visibility and management
           - Customer self-service where possible

        5. **Admin Dashboard**
           - Payment status visibility
           - Refund issuance
           - Customer payment history
           - Financial reporting

        6. **Compliance & Security**
           - PCI compliance via payment provider
           - GDPR compliance for EU
           - Fraud prevention
           - Audit logging

        User Journey - Customer Signup:
        - Before: Customer clicks "Subscribe"
        - During: Enters card info on secure form, submits
        - After: Instant subscription activation, confirmation email,
                 automatic monthly billing

        User Journey - Monthly Renewal:
        - Before: System detects renewal date approaching
        - During: Automatic charge processed
        - After: Customer gets receipt, continued service access

        User Journey - Failed Payment:
        - Before: Payment fails (expired card, insufficient funds)
        - During: System retries 3 times over 5 days, notifies customer
        - After: If still fails, account suspended with grace period

        Delight Factors:
        - Instant gratification for customers
        - Set it and forget it for renewals
        - Professional, trustworthy experience
        - Reduces admin burden dramatically

        Does this match your vision? Any changes?

User: Yes, that's exactly it. The smart retry logic is critical—we don't
      want to lose customers over temporary card issues.

---

[Checkpoint #3: Validation]

Claude: Here's the validation analysis:

        For Business/Product project:

        **Market Fit**:
        - Target market: Small businesses (25-250 employees) needing SaaS
        - Potential customers: Current 20-30 signups/month, growing
        - Addressable market: Thousands of small businesses in our vertical
        - Market expectation: Instant payment is standard for SaaS

        **Competitive Positioning**:
        - Competitors: Already offer instant payment processing
        - Our disadvantage: Manual invoicing losing us 40% of signups
        - This closes the gap: Matches competitor capability
        - Differentiation: Combined with our superior product features

        **Business Case**:
        - Revenue recovery: 40% abandonment = significant lost revenue
        - Cash flow improvement: 5-15 day wait → instant payment
        - Operational efficiency: Eliminate manual reconciliation
        - Scale enablement: Can handle 10x growth without more staff
        - Professional image: Builds trust and credibility

        **Pricing & Monetization**:
        - Payment processing fees: ~2.9% + $0.30 per transaction
        - Worth it: Customer acquisition and retention value >> fees
        - Monthly recurring revenue: More predictable cash flow
        - Reduced churn: Easier to maintain subscriptions

        **Strategic Fit**:
        - Critical for business growth
        - Enables trials and freemium models (future)
        - Foundation for multiple pricing tiers
        - Required for international expansion

        **Risks & Considerations**:
        - Payment provider selection: Stripe vs Braintree vs others
        - Integration complexity: Development effort significant
        - Data migration: Existing customers need to add cards
        - Compliance: Must get security and GDPR right
        - Customer communication: Change management for existing customers
        - Failed payment handling: Need solid retry and notification system
        - Edge cases: Refunds, disputes, fraud

        Does this validation make sense? Any additional considerations?

User: Yes. We're leaning toward Stripe—best developer experience. The
      existing customer migration is a concern, but we'll need to solve that.

Claude: Good choice. We should include migration plan in the implementation.

---

[Checkpoint #4: Viability Recommendation - CRITICAL]

Claude: Based on our discovery, my recommendation: PROCEED

        Rationale:

        This is a **critical business capability** with clear ROI:

        1. **Validated user problem**:
           - 40% signup abandonment is severe
           - Manual process provably doesn't scale
           - Competitive disadvantage is real

        2. **Strong business case**:
           - Revenue recovery: Capturing 40% more signups
           - Cash flow: Instant vs 5-15 day wait
           - Operational efficiency: Eliminate manual work
           - Enabler for growth: Can't scale without this

        3. **Viable solution**:
           - Clear vision with detailed requirements
           - Stripe provides proven infrastructure
           - Similar implementations successful elsewhere
           - Technical complexity manageable

        4. **Strategic importance**:
           - Foundational for business model
           - Required for competitive parity
           - Enables future monetization strategies

        Key findings:
        - Problem validated with concrete metrics (40% abandonment)
        - Solution addresses root cause
        - Strong ROI justification
        - Technical path clear (Stripe integration)
        - Risks identified and manageable

        What would you like to do?

        A) Proceed to Product Brief
           → Create comprehensive brief
           → Option to add user stories (recommended for complexity)

        B) Pivot to different approach
           → Explore alternative payment strategies

        C) Stop and document learnings
           → Not recommended given strong case

        D) Continue exploring
           → Dig deeper on specific areas

User: A - Proceed. This is critical and we need to move forward.

---

[Checkpoint #5: File Location]

Claude: Where would you like me to save the output?

        A) Single file: ./product-briefs/payment-processing.md (recommended)
           → Product Brief + User Stories in one document
           → Easier to share and reference

        B) Separate files:
           → ./product-briefs/payment-processing-brief.md
           → ./product-briefs/payment-processing-stories.md

        C) Custom location

User: A - Single file is fine

Claude: [Creating comprehensive Product Brief...]

---

[Checkpoint #6: Product Brief Review & Stage 2 Choice - CRITICAL]

Claude: I've created the Product Brief and saved it to:
        ./product-briefs/payment-processing.md

        Key sections:

        **User Problem**: Manual invoicing creates 40% signup abandonment,
        5-15 day payment delays, doesn't scale

        **Solution Vision**: Automated payment processing with instant
        signup, recurring billing, multi-payment methods, admin dashboard

        **Business Validation**: Critical for growth, strong ROI, competitive
        parity, enables scale

        **Estimated Scope**: Complex (~2-4 weeks), multiple integrations,
        compliance requirements, unknowns around migration and edge cases

        **Recommendation**: PROCEED - Critical business capability

        The brief is ready and comprehensive. Now you have a choice:

        What would you like to do next?

        A) Continue to user stories (Stage 2: ~15-20 minutes)
           → Translate into detailed user stories
           → Recommended for complex features like this
           → Creates clear requirements for architect

        B) Skip user stories - brief is sufficient
           → Less structured implementation approach
           → Not recommended for this complexity

        C) Request modifications to brief

        D) Pause and resume later

User: A - Let's create user stories. This needs structured implementation.

Claude: Great choice for a complex feature like this. Proceeding to Stage 2...
```

### Stage 2: Product Manager Translation (Abbreviated)

```
Claude: [Product Manager role loaded]
        [story-patterns.md auto-loaded]

        I'm now switching to Product Manager to translate this brief into
        actionable user stories. I'll focus on MVP scope and create testable
        acceptance criteria.

        [Reading Product Brief internally...]

---

[Checkpoint #7: MVP Scope]

Claude: I've analyzed the features and propose this MVP scope:

        **Must-have (Phase 1 / MVP)**:

        1. **Secure Card Payment Processing** - Critical for instant signup
           - Rationale: Core capability, blocks everything else

        2. **Automated Recurring Billing** - Essential for subscription model
           - Rationale: SaaS business model requires this

        3. **Failed Payment Handling** - Prevents subscription loss
           - Rationale: 3x retry with notifications minimizes churn

        4. **Basic Refund System** - Required for 30-day policy
           - Rationale: Customer trust and legal requirement

        5. **Admin Payment Dashboard** - Needed for operations
           - Rationale: Team needs visibility day one

        6. **Customer Payment History** - Self-service reduces support load
           - Rationale: Customers need to see their billing

        **Nice-to-have (Phase 2+)**:

        1. **ACH/Bank Transfer Support** - Requested but low volume
           - Rationale: Cards are 90% of demand, can add later

        2. **PayPal Integration** - International customers
           - Rationale: Small segment, validate demand first

        3. **Advanced Fraud Detection** - Beyond Stripe's built-in
           - Rationale: Start with Stripe's fraud prevention, enhance later

        4. **Detailed Financial Reporting** - Nice but not blocking
           - Rationale: Basic reporting sufficient for launch

        5. **Subscription Pause/Resume** - Edge case feature
           - Rationale: Can handle manually initially

        6. **Proration for Mid-Month Changes** - Complex edge case
           - Rationale: Rare scenario, manual handling acceptable

        **Rationale**:
        Minimum viable functionality to replace manual invoicing while
        delivering instant signup value. Phase 1 solves the core problem
        (40% abandonment) and enables automated billing. Phase 2 features
        improve experience but aren't blocking for launch.

        Does this prioritization work for you?

User: Yes, that makes sense. Let's get Phase 1 solid before adding complexity.

---

[Creating 12 user stories with detailed acceptance criteria...]

[Checkpoint #8: User Stories Review]

Claude: I've created 12 user stories for the MVP scope:

        **High Priority (Must-have)**:
        - Story 1: Secure card payment form integration
        - Story 2: Instant subscription activation
        - Story 3: Automated monthly recurring billing
        - Story 4: Failed payment retry logic
        - Story 5: Customer payment failure notifications
        - Story 6: Admin view payment status dashboard
        - Story 7: Customer view payment history
        - Story 8: Initiate refund from admin dashboard
        - Story 9: Customer request refund self-service
        - Story 10: Stripe webhook integration for events

        **Medium Priority (Important)**:
        - Story 11: Existing customer card migration flow
        - Story 12: Payment analytics and reporting

        **Dependencies**:
        - Story 2 depends on Story 1 (can't activate without payment)
        - Story 3 depends on Story 2 (billing requires active subscription)
        - Story 4 depends on Story 3 (retry requires billing system)
        - Story 8 depends on Story 6 (refund requires admin dashboard)
        - All others relatively independent

        [Show example stories...]

        ### Story 1: Secure Card Payment Form Integration

        **As a** prospective customer
        **I want** to enter my credit card information on a secure payment form
        **So that** I can instantly subscribe and start using the service

        **Context**: From Product Brief, instant signup is critical to solve
        40% abandonment rate. This story integrates Stripe's hosted payment
        form for PCI compliance. Foundation for all payment functionality.

        **Priority**: High

        **Dependencies**: None

        **Acceptance Criteria**:
        - [ ] Customer sees secure card payment form on subscription page
        - [ ] Form accepts card number, expiry, CVV, billing ZIP
        - [ ] Form validates card format in real-time
        - [ ] PCI-compliant (Stripe Elements, no card storage on our servers)
        - [ ] Successful payment returns token for subscription creation
        - [ ] Failed payment shows clear error message
        - [ ] Form displays loading state during processing
        - [ ] Form works on desktop and mobile devices
        - [ ] Form accessible via keyboard navigation
        - [ ] Error messages are screen-reader friendly
        - [ ] Stripe connection secured via TLS
        - [ ] Test mode available for development

        [... 11 more stories with full acceptance criteria ...]

        What would you like to do?

        A) Approve these stories
        B) Request modifications
        C) Need more detail on specific stories

User: Let me see Story 4 in detail—the failed payment retry logic.

Claude: [Shows Story 4 with complete acceptance criteria including retry
        schedule, notification timing, grace periods, etc.]

User: Perfect. Approve all stories.

---

[Creating Prioritized Task List...]

[Checkpoint #9: Final Output - CRITICAL]

Claude: User stories complete! Here's what I've created:

        **Output Files**:
        - ./product-briefs/payment-processing.md (Product Brief + User Stories)

        **Summary**:
        - 12 user stories created with detailed acceptance criteria
        - 10 must-have (Phase 1), 2 nice-to-have (Phase 2)
        - 6 prioritized tasks for architect
        - Comprehensive Requirements Summary included
        - Integration contract for task-preparation ready

        **MVP Scope (Phase 1)**:
        - Secure card payment processing
        - Automated recurring billing
        - Failed payment handling
        - Basic refunds
        - Admin dashboard
        - Customer payment history

        **Phase 2 Scope**:
        - ACH/bank transfers
        - PayPal integration
        - Advanced fraud detection
        - Detailed reporting
        - Subscription pause/resume
        - Proration for changes

        **Next Steps**:
        Ready for technical planning with task-preparation skill

        What would you like to do?

        A) Approve - ready for architect
        B) Request final modifications
        C) Add more user stories

User: A - Approve. This is comprehensive and ready for implementation planning.

Claude: ✅ Product discovery complete!

        **Outputs created**:
        - Product Brief with 5 sections (Problem, Solution, Validation, Scope,
          Recommendation)
        - 12 user stories with acceptance criteria
        - Requirements Summary for quick architect scanning
        - Prioritized task list with 6 tasks
        - Integration contract for task-preparation

        **Next steps**:

        → For technical planning:
          "use task preparation for payment processing"

          task-preparation will:
          - Read the Requirements Summary for context
          - Use User Stories as detailed requirements
          - Reference Prioritized Task List for work breakdown
          - Create technical implementation plan in ./plans/

        → Integration flow:
          Product Discovery → task-preparation → task-implementation

        **Time spent**:
        - Stage 0: 3 minutes
        - Stage 1: 35 minutes (deep discovery)
        - Stage 2: 18 minutes (user stories)
        - Total: 56 minutes

        ---

        Product discovery skill complete. Good luck with payment processing!
```

---

## Key Takeaways

### What Worked Well

✅ **Deep complexity appropriate**: 56 minutes allowed thorough exploration of complex system

✅ **Comprehensive problem validation**: Concrete metrics (40% abandonment) validated business case

✅ **Multi-stakeholder consideration**: Covered customers, admins, finance, support

✅ **Business validation rigorous**: Market fit, competitive analysis, ROI, strategic importance

✅ **Stage 2 recommended and valuable**: Complex feature benefits from structured user stories

✅ **Clear integration path**: Output ready for task-preparation with Requirements Summary

### Complexity Characteristics

**Deep mode (40-55 min)**:
- Complex system with multiple integrations
- Multiple user segments
- Significant business impact (40% abandonment, cash flow)
- Compliance and security requirements
- Many edge cases and unknowns
- Strategic importance to business

**Time breakdown**:
- Stage 0: 3 minutes
- Stage 1: 35 minutes (deep discovery)
- Stage 2: 18 minutes (detailed user stories)
- **Total: 56 minutes**

### When to Use Deep Mode

Use Deep complexity for:
- System-level features
- Payment/financial systems
- Multi-tenant features
- Significant business impact
- Multiple user types
- Compliance requirements
- Strategic capabilities
- Features with many unknowns

### Output Quality

**Product Brief**:
- Comprehensive 5-section structure
- Detailed problem validation with metrics
- Rich solution vision with 6 key features
- Thorough business validation
- Complex scope estimation with unknowns
- Clear PROCEED recommendation with rationale

**User Stories**:
- 12 stories covering MVP scope
- Detailed acceptance criteria (8-12 per story)
- Clear dependencies mapped
- MVP vs Phase 2 prioritization
- Requirements Summary for architect
- 6 prioritized tasks for implementation

**Ready for Handoff**:
- task-preparation receives complete requirements
- Technical architect has all context needed
- Implementation team has testable criteria
- Business stakeholders have clear scope

---

## Handoff to task-preparation

```
User: "use task preparation for payment processing"

task-preparation will:
1. Read ./product-briefs/payment-processing.md
2. Review Requirements Summary (quick context)
3. Deep-dive into 12 User Stories
4. Consider technical architecture for Stripe integration
5. Create implementation plan in ./plans/payment-processing.md
6. Break down into implementable steps with technical details
```

**Integration Contract ensures**:
- Architect understands user needs deeply
- Requirements are clear and testable
- Technical planning builds on solid foundation
- Implementation verifiable against acceptance criteria

---

*End of Complex Feature Example*
