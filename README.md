# GM Mainframe system

**Mainframe** is a GameMaker system for managing execution of logic within a frame. Its major components are:

- **Mainframe events**, which allow specific ordering and activation/deactivation of individual actions
- **Post-frame processing**, which uses the free time after core gameplay logic to perform tasks in the background

## Installation

- download the latest package version: [Alphish.Mainframe.\*.yymps](http://www.example.com)
- in your project, use the [Import Local Package feature](https://manual.gamemaker.io/monthly/en/#t=IDE_Tools%2FLocal_Asset_Packages.htm)
- import everything from the package
- put an instance of the `sys_Mainframe` object in the initial room
- enjoy!

For more details, read instructions in the [Overview documentation page](/Docs/01%20-%20Overview.md).

## Documentation

The following pages describe the package functionality in more detail:

- [Overview](/Docs/01%20-%20Overview.md) - roughly describes the package in general and has installation instructions
- [Mainframe Events](/Docs/02%20-%20Mainframe%20Events.md) - describes how to set up and use Mainframe events to organise the game logic
- [Post-frame Processing](/Docs/03-%20-%20Post-frame%20Processing.md) - describes how to use post-frame processing to do additional work in the background

Additionally, there's a simple demonstration of the package functionality, available here: [Mainframe Demo.yyz](http://www.example.com)

The [Demo Example documentation page](/Docs/04-%20-%20Demo%20Example.md) explains how Mainframe features are applied in the demo application, step by step.