[<< Back to home](https://github.com/Alphish/gm-mainframe)

**01 - Overview** | [02 - Mainframe Events >>](/Docs/02%20-%20Mainframe%20Events.md)

-----

# Overview

Mainframe is a system that manages execution of the game logic throughout each frame. It has two major components:

- **Mainframe events**, which organise actions to perform at specific points in the frame
- **Mainframe post-frame processing**, which uses the frame time available after core gameplay logic to perform additional tasks in the background

Mainframe events can help with properly ordering the gameplay logic. This is in contrast with GameMaker's built-in events, where you can't ensure execution order within a single event for the most part. You can read more about Mainframe events in the [Mainframe Events page](/Docs/02%20-%20Mainframe%20Events.md).

Mainframe post-frame processing uses the frame time remaining after core gameplay loop to perform any long-running tasks while maintaining the target framerate. You can read more about this functionality in the [Post-frame Processing page](/Docs/03%20-%20Post-frame%20Processing.md).

## Installation

In order to install the Mainframe system, download its [Local Package file](/Release/Alphish.Mainframe.0.8.0.yymps?raw=1). After that, follow the [GameMaker manual instructions](https://manual.gamemaker.io/monthly/en/#t=IDE_Tools%2FLocal_Asset_Packages.htm) to import the package; you should import all the assets in it.

The package contains:
- the Mainframe system object, called `sys_Mainframe` (along with its sprite for easier recognition)
- constructors for `MainframeEvent` and `MainframeEventAction` structures
- constructors for `MainframePostFrameProcess` and `MainframePostFrameAction` structures
- a set of Mainframe management functions packed into `funcs_Mainframe` script
- a constructor for `MainframeException` structure, used for representing various Mainframe usage errors

## In-game setup

The Mainframe system is expected to be used throughout the entire game run. Thus, it's best to place an instance of the `sys_Mainframe` object in the initial room and never destroy it. As a persistent object, it won't get cleaned up between rooms, either.

**Note:** Only one instance of `sys_Mainframe` object can exist at a time.

**Note:** You cannot use any Mainframe functionality (setting up events, post-frame processing etc.) before the Mainframe system instance is created. In particular, you cannot use it in raw script function (processed before the first room) or when creating earlier instances. If need be, you may [Instance Creation Order](https://manual.gamemaker.io/monthly/en/#t=The_Asset_Editors%2FRoom_Properties%2FRoom_Properties.htm%23creation_order) to ensure `sys_Mainframe` instance is created before Mainframe-dependent instances.

-----

**01 - Overview** | [02 - Mainframe Events >>](/Docs/02%20-%20Mainframe%20Events.md)
