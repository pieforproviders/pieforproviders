# Technical Decisions made for PieForProviders

This documents why certain technical decisions have been made.
This is the main document to search when trying to understand _why_ certain aspects of the system have been designed and implemented the way they are.

This might point to other sources and documents.


This is a format that can be used to document each main decision. Copy, paste, and fill in for each main decision.  
- Remember that a key value of this document is for someone to search it in the future when trying to understand the system.  Use keywords and descriptions that will help find answers.    

---

### Decision:

#### Why? (Rationales, Goals, Limitations, Risks, Unknowns, etc.):

##### Keywords / Areas affected:   

Author:  
Date:    
---

---



### Decision: No Rails Controller for Agencies

#### Why? (Rationales, Goals, Limitations, Risks, Unknowns, etc.):
I think for now we should remove the controller actions because we'll be using rake tasks to manage all data for Agencies. If we need routes later on, I'd rather add them in then.

##### Keywords / Areas affected:   
Rails, backend, db, models, agency

Author:  Kate Donaldson 

Date:  2020-08-08

---
