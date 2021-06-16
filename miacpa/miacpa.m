clc
clear all

load('..\..\traces.mat');
load('..\..\textin.mat');
load('..\..\keys.mat');
load('..\..\textout.mat');

sbox=[ 0x63 0x7c 0x77 0x7b 0xf2 0x6b 0x6f 0xc5 0x30 0x01 0x67 0x2b 0xfe 0xd7 0xab 0x76 0xca 0x82 0xc9 0x7d 0xfa 0x59 0x47 0xf0 0xad 0xd4 0xa2 0xaf 0x9c 0xa4 0x72 0xc0 0xb7 0xfd 0x93 0x26 0x36 0x3f 0xf7 0xcc 0x34 0xa5 0xe5 0xf1 0x71 0xd8 0x31 0x15 0x04 0xc7 0x23 0xc3 0x18 0x96 0x05 0x9a 0x07 0x12 0x80 0xe2 0xeb 0x27 0xb2 0x75 0x09 0x83 0x2c 0x1a 0x1b 0x6e 0x5a 0xa0 0x52 0x3b 0xd6 0xb3 0x29 0xe3 0x2f 0x84 0x53 0xd1 0x00 0xed 0x20 0xfc 0xb1 0x5b 0x6a 0xcb 0xbe 0x39 0x4a 0x4c 0x58 0xcf 0xd0 0xef 0xaa 0xfb 0x43 0x4d 0x33 0x85 0x45 0xf9 0x02 0x7f 0x50 0x3c 0x9f 0xa8 0x51 0xa3 0x40 0x8f 0x92 0x9d 0x38 0xf5 0xbc 0xb6 0xda 0x21 0x10 0xff 0xf3 0xd2 0xcd 0x0c 0x13 0xec 0x5f 0x97 0x44 0x17 0xc4 0xa7 0x7e 0x3d 0x64 0x5d 0x19 0x73 0x60 0x81 0x4f 0xdc 0x22 0x2a 0x90 0x88 0x46 0xee 0xb8 0x14 0xde 0x5e 0x0b 0xdb 0xe0 0x32 0x3a 0x0a 0x49 0x06 0x24 0x5c 0xc2 0xd3 0xac 0x62 0x91 0x95 0xe4 0x79 0xe7 0xc8 0x37 0x6d 0x8d 0xd5 0x4e 0xa9 0x6c 0x56 0xf4 0xea 0x65 0x7a 0xae 0x08 0xba 0x78 0x25 0x2e 0x1c 0xa6 0xb4 0xc6 0xe8 0xdd 0x74 0x1f 0x4b 0xbd 0x8b 0x8a 0x70 0x3e 0xb5 0x66 0x48 0x03 0xf6 0x0e 0x61 0x35 0x57 0xb9 0x86 0xc1 0x1d 0x9e 0xe1 0xf8 0x98 0x11 0x69 0xd9 0x8e 0x94 0x9b 0x1e 0x87 0xe9 0xce 0x55 0x28 0xdf 0x8c 0xa1 0x89 0x0d 0xbf 0xe6 0x42 0x68 0x41 0x99 0x2d 0x0f 0xb0 0x54 0xbb 0x16 ];

numtracesmat = size(traces{1});
maxnumtraces = numtracesmat(1);
numpoint = numtracesmat(2);
weights = ones(1, numpoint);
tracesnew = zeros(maxnumtraces, numpoint);
zScaled = zeros(256, numpoint);

for kguess = 1:256
    for bnum=1:16
        for tnum = 1:maxnumtraces
        hyp{kguess}(tnum, bnum) = 0;
        end
    end
end


for counter = 1:32
    for bnum=1:16
        for iteration = 1:(200/10)
        
        partialsuccess{counter}(bnum, iteration) = 0;
        
    
        end
    end
end



for counter = 1:32
    iteration = 1;
   
    for bnum = 5:5
        for kguess = 0:255
           for tnum = 1:maxnumtraces
                   size1 = size(de2bi(textin{counter}(tnum, bnum)));
                   size2 = size(de2bi(kguess));
                   a1 = [de2bi(textin{counter}(tnum, bnum))];
                   a2 = [de2bi(kguess)];
                   x1 = [a1 zeros(1, 8-size1(2))];
                   x2 = [a2 zeros(1, 8-size2(2))];
                   hyp{kguess+1}(tnum, bnum) = HamWt(de2bi(sbox(bi2de(xor(x1, x2))+1))); 
           end
        end
    end
    
    for numtraces=10:10:200
        %variance analysis starts here
        for point = 1:numpoint
            traceVar(point) = var(traces{counter}(1:numtraces, point));
        end
        
        meanvar = mean(traceVar);
        varvar = var(traceVar);
        
        for bnum = 5:5
            
            z = zeros(256, numpoint);
            cpaout = zeros(256,numpoint);
            maxcpa = zeros(256,1);
            cpaoutabs = zeros(256,numpoint);
            
            
            for kguess= 0:255
                    for point = 1:numpoint
                       z(kguess+1, point) = nmi(hyp{kguess+1}(1:numtraces, bnum), round((traces{counter}(1:numtraces, point))));
                    end
            end


            %removing unecessary key hypothesis
                for kguess = 0:255
                    if max(z(kguess+1, :)) < max(max(z)) * 0.2
                        z(kguess+1,:) = 0;
                    end

                    %need to define pdf of the distribution
                    mu = mean(z(kguess+1, :));
                    sigma = std(z(kguess+1, :));

                    %y = @(inp, mu, sigma) normpdf(inp, mu, sigma );
                    %y = @(ab) pdf('Normal',ab, 1 );
                    %b = ones(1, 5000);

                    %phat = mle(maskedTraceVar(:), 'pdf', @(inp1, inp2) deneme(inp1, inp2 ), 'start', [mu sigma] );

                    %apply t-test
                    phat(kguess + 1) =  abs(meanvar - mu) ./ sqrt(abs(varvar + sigma)) ; 

                end
            
            %update cpaoutabs
            for i = 1:numpoint
            zScaled(:,i) =  z(:,i) ./ transpose(phat);
            end
            
            weights = ones(1, numpoint);
            weights = weights .* mean(zScaled);
            
            %update traces
             %update cpaoutabs modified for second version of runs
           % for i = 1:numpoint
            %cpaoutabsScaled(:,i) =  (cpaoutabs(:,i) - transpose(mean(transpose(cpaoutabs(:,:))))).* transpose((1+1 / transpose(phat)));
            %end
            
            for i = 1:numtraces
                tracesnew(i,:) = (traces{counter}(i,:) -  transpose(mean(traces{counter}(i,:)))) .* (1+(weights));
            end
            
            
            for kguess = 0:255
               meanh = mean(hyp{kguess+1}(1:numtraces,bnum));
               meant = mean(mean(tracesnew(1:numtraces, :)));
               sumnum = zeros(1,numpoint);
               sumden1 = zeros(1,numpoint);
               sumden2 = zeros(1,numpoint);

               for tnum = 1:numtraces
                   hdiff = hyp{kguess+1}(tnum, bnum) - meanh;
                   tdiff = tracesnew(tnum, :) - meant;
                   sumnum = sumnum + hdiff * tdiff;
                   sumden1 = sumden1 + hdiff .* hdiff;
                   sumden2 = sumden2 + tdiff .* tdiff;
               end

               cpaout(kguess+1,:) = sumnum ./ sqrt(sumden1 .* sumden2);
               maxcpa(kguess+1) = max(abs(cpaout(kguess+1,:)));
               cpaoutabs(kguess+1,:) = abs(cpaout(kguess+1,:));
            end
            
            
            for i=1:256
               if max(maxcpa) == maxcpa(i)
                   if key{counter}(numtraces, bnum) == i-1
                       partialsuccess{counter}(bnum, iteration) = partialsuccess{counter}(bnum, iteration) + 1;

                   end

               end
            end
        
        end
               
        iteration = iteration + 1;  
    end
          
end

sumsuccess= zeros(1,20);
for i = 1:32
for j = 1:1:20
   sumsuccess(j) =  sumsuccess(j) + partialsuccess{i}(5,j);
end
end
