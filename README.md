# Home Assessment

## Architecture 

Implemented using MVVM-C architecture, following patters defined and provided parts of the app. 
I've added Coordinator to the architecture, because it more-or-less industry standard now. There only one coordinator, because the flow is very simple for bigger application I'll prefer to use more coordinators, basically having one coordinator for each screen + flow coordinators to arrange navigation between adjacent screens and control the sequence/presentation. 

## Testing

Due to lack of time I’ve implemented only basic tests for services I’ve introduced. With more time I’d covered ViewModels, add Snapshot tests for ViewControllers and Cells. 

Tests for ProductService includes have both with «Production» api, and Stubbed response both (I definitely we keep only Stubbed version for Production app, so test will be more reliable and predictable. I’ll add «integration tests» with production API, as separate project, if I have more time.  Tests for offers works only with stubbed JSON and mock URL session. 

## Know issues

Although code provided with the task is generally good, however responses from backend aren’t consistent. In particular I got error on attempt to retrieve image for keys on ProductDetails. Keys for images on Listing is working fine, so I’m assuming it’s problem on backend. 

While showing details page, listing images was provided, but higher resolution details image failed. I’ve added a few lines to show alert with the error. 

## Improvements, if I have more time to work on the app

1. Authentication. It wasn’t in the tech task to implement authentication, so I just added valid authorisation key to the request in the api, instead of creating dedicated service and screen. If I had to do Authentication, I’ll save that key into keychain. 
2. User-friendly errors. - It very good approach to supply users with friendly errors. It was definitely out of scope in that task.
3. UnitTests - essential for safe refactoring, and reliability of application in general. Good to have good reliable tests, before starts changing components. 
4. In-memory cache service for images. I’ve used static variable to keep fetched images in memory. I’ll wrap it up into dedicated service behind protocol. And make sure it supports Memory Warnings to wipe cache, even though memory warnings are not so big threat as they used to be with early iPhones
5. Dedicated coordinators to build and combine each screen independently. 

#### Hope you enjoy reviewing and hope to hear your feedback soon :) 
