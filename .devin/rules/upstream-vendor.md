---
trigger: model_decision
description: When evidence points at the upstream provider rather than at our middleware.
---

# When it looks like the provider

The middleware translates between the banking core and the upstream
personalisation engine. When something breaks, the expensive question is whose
side it is on.

**Never call it the provider's without a positive finding.** "Not ours" does not
count. One of these is needed:

- The request we send is valid against the agreed contract and the response coming
  back is not.
- The same payload gives different results on two consecutive calls with nothing
  changing on our side.
- The provider returns a 5xx or a timeout carrying our correlation id on their end.

With that, the session outcome is `handoff`: a package with the request sent, the
response received, the correlation id, the time window, and the contract clause
being broken. Not one line of speculation about their code.

Without it, the outcome is `cannot_reproduce` or you keep digging. Handing over a
problem with no proof costs more than two more hours of investigation: a week of
back-and-forth and the ticket returns unchanged.
