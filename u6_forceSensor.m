%
% 2 channel stream of AIN0 and AIN1 example using MATLAB, .NET and the UD
% driver.
%
% support@labjack.com
%

clc %Clear the MATLAB command window
clear %Clear the MATLAB variables

ljasm = NET.addAssembly('LJUDDotNet'); %Make the UD .NET assembly visible in MATLAB
ljudObj = LabJack.LabJackUD.LJUD;

i = 0;
k = 0;
ioType = 0;
channel = 0;
dblValue = 0;
dblCommBacklog = 0;
dblUDBacklog = 0;
scanRate = 1000;
delay = 0.01; %in seconds
duration = 5; %in seconds
numScans = 2*scanRate*delay;  %2x the expected # of scans (2*scanRate*delayms/1000)
numScansRequested = 0;
adblData = NET.createArray('System.Double', 4000);  %Max buffer size (#channels*numScansRequested)
loopAmount = duration/delay; %Number of times to loop and read stream data
% Variables to satisfy certain method signatures
dummyInt = 0;
dummyDouble = 0;
dummyDoubleArray = [0];

try
    %Read and display the UD version.
    disp(['UD Driver Version = ' num2str(ljudObj.GetDriverVersion())])

    %Open the first found LabJack U6.
    [ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.U6, LabJack.LabJackUD.CONNECTION.USB, '0', true, 0);

   %Configure AIN2 for +/- 1 volt range.  This applies to any
%reading, single-ended or differential, where the positive
%channel is AIN2. ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.AIN_RESOLUTION, 0, 0, 0);
    
    %Configure the analog input range on channel 0 for bipolar +-10 V(LJ_rgBIP10V).
    gain = ljudObj.StringToConstant('LJ_rgBIP10V');
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_AIN_RANGE, 2, gain, 0, 0);
    
    %Set the scan rate.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.STREAM_SCAN_FREQUENCY, scanRate, 0, 0);
    
    %Give the driver a 5 second buffer (scanRate * 2 channels * 5 seconds).
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.STREAM_BUFFER_SIZE, scanRate*2*5, 0, 0);
    
    %Configure reads to retrieve whatever data is available without waiting (wait mode LJ_swNONE).
    %See comments below to change this program to use LJ_swSLEEP mode.
    LJ_swNONE = ljudObj.StringToConstant('LJ_swNONE');
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.STREAM_WAIT_MODE, LJ_swNONE, 0, 0);
    
    %Define the scan list as AIN2
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.CLEAR_STREAM_CHANNELS, 0, 0, 0, 0);
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.ADD_STREAM_CHANNEL, 2, 0, 0, 0);

    
    %Execute the list of requests.
    ljudObj.GoOne(ljhandle);
    
    %Get all the results just to check for errors.
    [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetFirstResult(ljhandle, ioType, channel, dblValue, dummyInt, dummyDouble);
    finished = false;
    while finished == false
        try
            [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetNextResult(ljhandle, ioType, channel, dblValue, dummyInt, dummyDouble);
        catch e
            if(isa(e, 'NET.NetException'))
                eNet = e.ExceptionObject;
                if(isa(eNet, 'LabJack.LabJackUD.LabJackUDException'))
                    if(eNet.LJUDError == LabJack.LabJackUD.LJUDERROR.NO_MORE_DATA_AVAILABLE)
                        finished = true;
                    end
                end
            end
            %Report non NO_MORE_DATA_AVAILABLE error.
            if(finished == false)
                throw(e)
            end
        end
    end
    
    %Start the stream.
    [ljerror, dblValue] = ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.START_STREAM, 0, 0, 0);
    
    %The actual scan rate is dependent on how the desired scan rate divides into
    %the LabJack clock.  The actual scan rate is returned in the value parameter
    %from the start stream command.
    disp(['Actual Scan Rate = ' num2str(dblValue)])
    disp(['Actual Sample Rate = ' num2str(1*dblValue) sprintf('\n')]) % # channels * scan rate

    F =[];
     
    %Read data
    for i=1:loopAmount %Loop will run the number of times specified by loopAmount variable
    timestamp = i*delay;    
        %Since we are using wait mode LJ_swNONE, we will wait a little,
        %then read however much data is available.
        %Thus this delay will control how fast the program loops and how
        %much data is read each loop.  An alternative common method is to
        %use wait mode LJ_swSLEEP where the stream read waits for a certain
        %number of scans.  In such a case you would not have a delay here,
        %since the stream read will actually control how fast the program
        %loops.
        %
        %To change this program to use sleep mode,
        %	-change numScans to the actual number of scans desired per read,
        %	-change wait mode addrequest value to LJ_swSLEEP,
        %	-comment out the following Thread.Sleep command.
        
        pause(delay);	%Remove if using LJ_swSLEEP.
        
        %Init array to store data
        adblData = NET.createArray('System.Double', 1*numScans);  %Max buffer size (#channels*numScansRequested)
        
        %Read the data.  We will request twice the number we expect, to
        %make sure we get everything that is available.
        %Note that the array we pass must be sized to hold enough SAMPLES, and
        %the Value we pass specifies the number of SCANS to read.
        numScansRequested = numScans;
        %Use eGetPtr when reading arrays in 64-bit applications. Also
        %works for 32-bits.
        [ljerror, numScansRequested] = ljudObj.eGetPtr(ljhandle, LabJack.LabJackUD.IO.GET_STREAM_DATA, LabJack.LabJackUD.CHANNEL.ALL_CHANNELS, numScansRequested, adblData);
        
        %The displays the number of scans that were actually read.
        disp(['Iteration # = ' num2str(i)])
        disp(['Number read = ' num2str(numScansRequested)])
        
        %This displays just the first scan.
        disp(['First scan = ' num2str(adblData(1))])
        F =[F ;timestamp adblData(1) ];
        
        %Retrieve the current backlog.  The UD driver retrieves stream data from
        %the U6 in the background, but if the computer is too slow for some reason
        %the driver might not be able to read the data as fast as the U6 is
        %acquiring it, and thus there will be data left over in the U6 buffer.
        [ljerror, dblCommBacklog] = ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.GET_CONFIG, LabJack.LabJackUD.CHANNEL.STREAM_BACKLOG_COMM, dblCommBacklog, dummyDoubleArray);
        disp(['Comm Backlog = ' num2str(dblCommBacklog)])

        [ljerror, dblUDBacklog] = ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.GET_CONFIG, LabJack.LabJackUD.CHANNEL.STREAM_BACKLOG_UD, dblUDBacklog, dummyDoubleArray);
        disp(['UD Backlog = ' num2str(dblUDBacklog) sprintf('\n')])
    end
    
    %Stop the stream
    ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.STOP_STREAM, 0, 0, 0);
    
    save('dataForce.mat','F');
    
    disp('Done')
catch e
   disp('Erreur'); %howErrorMessage(e)
end