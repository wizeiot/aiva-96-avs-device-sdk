# Amazon Alexa AVS Device SDK using AiVA-96 & DragonBoard 410c

The **WizeIoT’s AiVA mezzanine board for DragonBoard and 96Boards** enables developers of the smart home devices such as smart speaker, smart panels, kitchen equipment and other commercial and industrial electronics products to evaluate and prototype far-field hands-free voice interface using Amazon Alexa, Google Assistant, Microsoft Cortana voice service.

Built around XMOS XVF3000 voice processor with direct interfacing to a line array of four digital microphones, the AiVA board is an ideal platform for developers who want to integrate AI speaker into their products.

Alexa Voice Service (AVS) is Amazon’s intelligent voice recognition and natural language understanding service that allows you as a developer to voice-enable any connected device that has a microphone and speaker.

This project provides a step-by-step walkthrough to help you build a hands-free Alexa Voice Service (AVS) prototype in 60 minutes, using wake word engines from **KITT.AI**. Now, instead of pushing a button to "start listening", you can now just say the wake word "Alexa", much like the Amazon Echo.

To find out more, visit: https://www.wizeiot.com/aiva-96/ home page and: https://developer.amazon.com/alexa-voice-service

This repository provides a simple-to-use automated script to install the [Amazon AVS Device SDK](https://github.com/alexa/avs-device-sdk) on a [DragonBoard 410c](https://developer.qualcomm.com/hardware/dragonboard-410c) and configure the Dragon Board 410c to use the AiVA-96 for AVS for audio.

Prerequisites
---
You will need:

- [AiVA-96 board](https://www.wizeiot.com/aiva-96/)
- [DragonBoard 410c](https://www.96boards.org/product/dragonboard410c/) or [compatible 96Boards](https://www.96boards.org/products/)
- [96Boards Compliant Power Supply](http://www.96boards.org/product/power/)
- MicroSD card (min. 16GB)
- Monitor with HDMI input, HDMI cable
- USB keyboard and mouse
- Wi-Fi with internet connectivity

You will also need an Amazon Developer account: https://developer.amazon.com

Hardware setup
---
- Make sure the DragonBoard is powered off
- Connect I/O devices (Monitor, Keyboard, etc...)
- Connect AiVA-96 boards on top of DragonBoard
- Connect AiVA-96 MEMS mic board and speakers
- Power on your DragonBoard 410c with 96Boards compliant power supply
- To make sure the microphone and speakers are connected successfully, go to Application Menu -> Sound & Video -> PulseAudio Volume Control and check the input and output device, set as "WizeIoT AiVA-96 DevKit (UAC1.0) Analog Stereo". 

    ![AiVA-96 and DB410c](https://github.com/daehahn/aiva-96-alexa-avs-sample/wiki/assets/aiva_db410c.jpg)

AVS SDK installation and Dragon Board 410c audio setup
---
Full instructions to install the AVS SDK on to a Dragon Board 410c and configure the audio to use the AiVA-96 are detailed in the Getting Started Guide available from: https://www.wizeiot.com/aiva-96/ home page.

Brief instructions and additional notes are below:


1. You'll need to register a device and create a security profile at developer.amazon.com. [Click here](https://github.com/alexa/avs-device-sdk/wiki/Create-Security-Profile) for step-by-step instructions.

    IMPORTANT: You should download **`'config.json'`** file from step 4 of 'Create a Security Profile' section of the instructions.

2. Install Debian (Stretch) on the DragonBoard 410c
   + You shoud use [Debian 17.09](http://releases.linaro.org/96boards/dragonboard410c/linaro/debian/17.09/dragonboard410c_sdcard_install_debian-283.zip),  [Debian 18.01](http://releases.linaro.org/96boards/dragonboard410c/linaro/debian/18.01/dragonboard-410c-sdcard-installer-buster-359.zip) or higher. Note: '*apt-get upgrade*' from 18.01 possibly bring boot crash. You may hold kernel upgrade with below command line, before package upgrade.
    ```
    sudo apt-mark hold linux-image-4.14.0-qcomlt-arm64
    ```   

   + Write downloaded image file to your MicroSD card with [Etcher](https://etcher.io/) or other image writer software.
   + Turn on DragonBoard 410c's 'SD BOOT' dip switch and power on to install Debian.

3. Open a terminal on the Dragon Board 410c and clone this repository
    ```
    cd ~; git clone https://github.com/wizeiot/aiva-96-avs-device-sdk.git
    ```   

4. Run the installation script
    ```
    cd aiva-96-avs-device-sdk/
    bash automated_install.sh
    ```
    IMPORTANT: Before running the script, place your **`'config.json'`** into `aiva-96-avs-device-sdk` folder. You can use [WinSCP](https://winscp.net/eng/download.php) or [FileZillia](https://filezilla-project.org/download.php?type=client) for transfer file. *Initial Debian password should be same as id.* Installation takes 30 mins ~ 1 hour depending on your internet speed.

5. Alternative way to setup SDK: Run the setup script with config.json and the device serial number (DSN) as arguments. You can either provide your own DSN, or use the system default (123456). The DSN can be any unique alpha-numeric string (up to 64 characters). You should use this string to identify your product or application instance. Many developers choose to use a product's SKU for this value.

    For example:
    ```
    sudo bash setup.sh config.json -s 998987
    ```
    **Note:** If you don't supply a DSN, then the default value 123456 will be generated by the SDK.


Authorize and run
---
When you run the sample app for the first time, you'll need to authorize your client for access to AVS.

1. Initialize the sample app:
    ```
    sudo bash startsample.sh
    ```

2. Wait for the sample app to display a message like this:
    ```
    ######################################################
    #       > > > > > NOT YET AUTHORIZED < < < < <       #
    #####################################################

    ############################################################################################
    #     To authorize, browse to: 'https://amazon.com/us/code' and enter the code: {XXXX}     #
    ############################################################################################
    ```

3. Use a browser (either your PC or DragonBoard 410c) to navigate to the [authorize URL](https://amazon.com/us/code) specified in the message from the sample app.
4. Authenticate using your Amazon user credentials.
5. Enter the code specified in the message from sample app.
6. Select “Allow”.
7. Wait (it may take as long as 30 seconds) for CBLAuthDelegate to successfully get an access and refresh token from Login With Amazon (LWA). At this point the sample app will print a message like this:
    ```
    ########################################
    #       Alexa is currently idle!       #
    ########################################
    ```
8. You are now ready to use the sample app. The next time you start the sample app, you will not need to go through the authorization process.

9. Troubleshooting: This helps us do a simple speaker and microphone test, just to make sure that the hardware is functional.
    ```
    $ speaker-test -t wav
    $ arecord --format=S16_LE --duration=5 --rate=16000 --file-type=raw out.raw
    $ aplay --format=S16_LE --rate=16000 --file-type=raw out.raw
    ```

Integration and unit tests
---
You can run integration and unit tests using this command: 

    sudo bash test.sh


Enjoy your Google Assistant and don't forget to visit https://www.iotoi.io community for find out more projects. 

Important considerations
---
* Review the AVS [Terms & Agreements](https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/support/terms-and-agreements).  

* The earcons associated with the sample project are for **prototyping purposes only**. For implementation and design guidance for commercial products, please see [Designing for AVS](https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/content/designing-for-the-alexa-voice-service) and [AVS UX Guidelines](https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/content/alexa-voice-service-ux-design-guidelines).
