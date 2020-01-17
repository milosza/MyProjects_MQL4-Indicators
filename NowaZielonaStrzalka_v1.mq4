#property indicator_chart_window    // Indicator is drawn in the main window
#property indicator_buffers 2       // Number of buffers for signals
#property indicator_color1 Green    // Color of BUY signal
#property indicator_color2 Red      // Color of SELL signal
 
extern int History  = 40320;            // Amount of bars in calculation history
extern int Bar_Index = 1;             // Bar index calculated 0 = actual incompleted, 1 = last completed, 2 = second completed... 
extern int Vertical_Shift = 10;       // Vertical shift of drawing in points
extern bool Show_Mlot = True;
extern bool Show_SpadajacaGwiazda = True;
extern bool Show_Przenikanie = True;
extern bool Show_ZaslonaCiemnejChmury = True;
extern bool Show_ObjecieHossy = True;
extern bool Show_ObjecieBessy = True;
extern bool Show_GwiazdaPolarna = True;
extern bool Show_GwiazdaWieczorna = True;

double IndBuf_0[],IndBuf_1[];       // Declaring arrays for indicator buffers
double price, csi, rsi, sma10, sma10_2, sma40; // Declaring aux variables for indicator strategy
bool trend_up_cont, trend_down_cont, trend_up_break, trend_down_break, aux_csi;
string time;             


//--------------------------------------------------------------------
int init()                          // Preparing to draw - init()
  {
   SetIndexBuffer(0,IndBuf_0);         // Assigning an array to a buffer
   SetIndexStyle (0,DRAW_ARROW,STYLE_SOLID,1);// Arrow style
   SetIndexArrow(0,233); // Arrow code from Windigit font
   SetIndexLabel(0,"Buy");
   
   SetIndexBuffer(1,IndBuf_1);         // Assigning an array to a buffer
   SetIndexStyle (1,DRAW_ARROW,STYLE_SOLID,1);// Arrow style
   SetIndexArrow(1,234); // Arrow code from Windigit font
   SetIndexLabel(1,"Sell");
   return;                          
  }
//--------------------------------------------------------------------
int start()                         // Start drawing - start()
  {
   int i,                           // Bar index
       Counted_bars;                // Number of counted bars

//--------------------------------------------------------------------
   Counted_bars=IndicatorCounted(); // Number of counted bars
   i=Bars-Counted_bars-1;           // Index of the first uncounted
      if (i>History-1)              // If too many bars ..
      i=History-1;                  // ..calculate for specific amount.
   while(i>=Bar_Index)                      // Loop for uncounted bars
     {
     price = Close[i];
     time = TimeToStr(iTime(Symbol(),Period(),i),TIME_DATE|TIME_SECONDS);
     IndBuf_0[i] = 0;
     IndBuf_1[i] = 0;
     
     csi = iCustom(NULL,0,"Candle Sizes",0,i); // Candle Sizes custom indicator import
     rsi = iCustom(NULL,0,"RSI",0,i); // RSI custom indicator import
     sma10 = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, i);
     sma10_2 = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, i+1);
     sma40 = iMA(NULL, 0, 40, 0, MODE_SMA, PRICE_CLOSE, i);
     
// BUY/SELL PRIMARY CONDITIONS ----------------------------------------------
      if(csi >= 11 // Candle Sizes indicator bigger than 11
         ) aux_csi = True;
         else aux_csi = False;
      if(
         aux_csi == True // Candle Sizes ok
         //&& rsi <= 35 // RSI below 35   
         && (sma10 > sma40 && sma10_2 < sma10)   
        ) trend_up_cont = True;
        else trend_up_cont = False;     
      if(
         aux_csi == True // Candle Sizes ok
         //&& rsi <= 35 // RSI below 35   
         && (sma10 > sma40 && sma10_2 > sma10)
        ) trend_up_break = True;
        else trend_up_break = False;            
      if(
         aux_csi == True // Candle Sizes ok
         //&& rsi >= 65 // RSI over 65   
         && (sma10 < sma40 && sma10_2 > sma10) 
        ) trend_down_cont = True;
        else trend_down_cont = False;  
      if(
         aux_csi == True // Candle Sizes ok
         //&& rsi >= 65 // RSI over 65   
         && (sma10 < sma40 && sma10_2 < sma10) 
        ) trend_down_break = True;
        else trend_down_break = False;              
// CANDLE PATTERNS ----------------------------------------------------------

// wzrost - młot 30%
      if(
         MathAbs(Open[i] - Close[i]) <= (0.3*(High[i] - Low[i])) //Candlestick Body is equal or smaller than 0,3 Candlestick Range
         && Close[i] >= (High[i]-(0.3*(High[i] - Low[i]))) //Candlestick Close is equal or higher than 0,7 Candlestick High
         && Open[i] >= (High[i]-(0.3*(High[i] - Low[i]))) //Candlestick Open is equal or higher than 0,7 Candlestick High
         && trend_up_cont == True
         && Show_Mlot == True
        )
      {
      IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar
      price = Close[i];
      Print("Młot 30%, (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target buy: ",DoubleToString(price,Digits));
      //IndBuf_1[i]=High[i]+Vertical_Shift*Point;              // Value of 1st buffer on i bar  
      //ObjectCreate("data", OBJ_TEXT, 0, Time[i], High[i]);
      //ObjectSetText("data","Młotek 30%",10,"Times New Roman", Red);
      //ObjectSet("data",OBJPROP_ANGLE,50);  
      }   

// wzrost - młot 50%
      if(
         Close[i] > Open[i]     
         && MathAbs(Open[i] - Close[i]) >= (0.3*(High[i] - Low[i])) //Candlestick Body is equal or higher than 0,3 Candlestick Range
         && MathAbs(Open[i] - Close[i]) <= (0.5*(High[i] - Low[i])) //Candlestick Body is equal or smaller than 0,5 Candlestick Range
         && Close[i] >= (High[i]-(0.5*(High[i] - Low[i]))) //Candlestick Close is equal or higher than 0,5 Candlestick High
         && Open[i] >= (High[i]-(0.5*(High[i] - Low[i]))) //Candlestick Open is equal or higher than 0,5 Candlestick High
         && trend_up_cont == True
         && Show_Mlot == True
         )     
       {
       IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar
       price = Close[i];
       Print("Młot 50% (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target buy: ",DoubleToString(price,Digits));
       }

// wzrost - przenikanie
      if(
         Close[i] > Open[i]
         && Open[i+1] > Close[i+1]     
         && Close[i] > (Open[i+1]-(0.5*(Open[i+1] - Close[i+1]))) //Candlestick Close is higher than 0,5 Candlestick Body
         && Close[i] < Open[i+1] //Candlestick Close is lower than previous Candlestick Open
         && Open[i] <= Close[i+1] //Candlestick Open is equal or lower than previous Candlestick Close
         && High[i] < (Close[i]+(Close[i]-Open[i])) //Candlestick High is shorter than Candlestick Body
         && trend_up_cont == True
         && Show_Przenikanie == True
         )     
      {
      IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar
      price = Close[i];
      Print("Przenikanie (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target buy: ",DoubleToString(price,Digits));
      }
      
// wzrost - objecie hossy
      if(
         Close[i] > Open[i]
         && Open[i+1] > Close[i+1]     
         && Open[i] <= Close[i+1] //Candlestick Open is lower than previous Candlestick Close
         && Close[i] >= Open[i+1] //Candlestick Close is higher than previous Candlestick Open
         && High[i] < (Close[i]+(1*(Close[i]-Open[i]))) //Candlestick High is shorter than Candlestick Body
         //&& (Open[i+1]-Close[i+1]) > (0.6*(Close[i]-Open[i])) //previous candle body similar to actual candle
         && trend_up_cont == True
         && Show_ObjecieHossy == True
         )     
      {
      IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar
      price = Close[i];
      Print("Objecie hossy (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target buy: ",DoubleToString(price,Digits));
      }

// wzrost - gwiazda poranna
      if(
         Close[i] > Open[i]
         && Open[i+2] > Close[i+2]     
         && Close[i] > (Open[i+2]-(0.5*(Open[i+2] - Close[i+2]))) //Candlestick Close is higher than 0,5 Candlestick Body
         //&& Close[i] < Open[i+2] //Candlestick Close is lower than previous Candlestick Open
         && Open[i] <= Close[i+2] //Candlestick Open is equal or lower than previous Candlestick Close
         && MathAbs(High[i+1] - Low[i+1]) < (1*MathAbs(High[i] - Low[i])) //
         && MathAbs(Open[i+1] - Close[i+1]) < (0.3*MathAbs(Open[i] - Close[i])) //
         && High[i] < (Close[i]+(Close[i]-Open[i])) //Candlestick High is shorter than Candlestick Body
         && trend_up_cont == True
         && Show_GwiazdaPolarna == True
         )     
      {
      IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar
      price = Close[i];
      Print("Gwiazda polarna (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target buy: ",DoubleToString(price,Digits));
      }
     
//spadek - spadajaca gwiazda 30% / odwrócony młot      
      if(
         MathAbs(Open[i] - Close[i]) <= (0.3*(High[i] - Low[i])) //Candlestick Body is equal or smaller than 0,3 Candlestick Range
         && Close[i] <= (Low[i]+(0.3*(High[i] - Low[i]))) //Candlestick Close is equal or smaller than 0,3 Candlestick Low
         && Open[i] <= (Low[i]+(0.3*(High[i] - Low[i]))) //Candlestick Open is equal or smaller than 0,3 Candlestick Low
         && trend_down_cont == True
         && Show_SpadajacaGwiazda == True
        )
      {
      IndBuf_1[i]=High[i]+Vertical_Shift*Point;             // Value of 1 buffer on i bar
      price = Close[i];
      Print("Spadająca gwiazda 30% (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target sell: ",DoubleToString(price,Digits));
      //IndBuf_1[i]=High[i]+Vertical_Shift*Point;              // Value of 1st buffer on i bar  
      //ObjectCreate("data", OBJ_TEXT, 0, Time[i], High[i]);
      //ObjectSetText("data","Młotek 30%",10,"Times New Roman", Red);
      //ObjectSet("data",OBJPROP_ANGLE,50);  
      }   

//spadek - spadajaca gwiazda 50% / odwrócony młot      
      if(         
         Close[i] < Open[i]     
         && MathAbs(Open[i] - Close[i]) >= (0.3*(High[i] - Low[i])) //Candlestick Body is equal or higher than 0,3 Candlestick Range
         && MathAbs(Open[i] - Close[i]) <= (0.5*(High[i] - Low[i])) //Candlestick Body is equal or smaller than 0,5 Candlestick Range
         && Close[i] <= (Low[i]+(0.5*(High[i] - Low[i]))) //Candlestick Close is equal or smaller than 0,5 Candlestick Low
         && Open[i] <= (Low[i]+(0.5*(High[i] - Low[i]))) //Candlestick Open is equal or smaller than 0,5 Candlestick Low
         && trend_down_cont == True
         && Show_SpadajacaGwiazda == True
        )
      {
      IndBuf_1[i]=High[i]+Vertical_Shift*Point;             // Value of 1 buffer on i bar
      price = Close[i];
      Print("Spadająca gwiazda 50% (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target sell: ",DoubleToString(price,Digits));  
      }  

// spadek - zasłona ciemnej
      if(
         Close[i] < Open[i]
         && Close[i+1] > Open[i+1]      
         && Close[i] < (Close[i+1]-(0.5*(Close[i+1]-Open[i+1]))) //Candlestick Close is lower than 0,5 Candlestick Body
         && Close[i] > Open[i+1] //Candlestick Close is higher than previous Candlestick Open
         && Open[i] >= Close[i+1] //Candlestick Open is equal or higher than previous Candlestick Close
         && Low[i] > (Close[i]-(Open[i]-Close[i])) //Candlestick Low is shorter than Candlestick Body   
         && trend_down_cont == True
         && Show_ZaslonaCiemnejChmury == True
         )  
      {
      IndBuf_1[i]=High[i]+Vertical_Shift*Point;             // Value of 1 buffer on i bar
      price = Close[i];
      Print("Zasłona ciemnej chmury (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target sell: ",DoubleToString(price,Digits));       
      } 
      
// spadek - objecie bessy
      if(
         Close[i] < Open[i]
         && Open[i+1] < Close[i+1]     
         && Close[i] <= Open[i+1] //Candlestick Close is lower than previous Candlestick Open
         && Open[i] >= Close[i+1] //Candlestick Open is higher than previous Candlestick Close
         && Low[i] > (Close[i]-(Open[i]-Close[i])) //Candlestick Low is shorter than Candlestick Body   
         //&& (Open[i+1]-Close[i+1]) > (0.6*(Close[i]-Open[i])) //previous candle body similar to actual candle
         && trend_down_cont == True
         && Show_ObjecieBessy == True
         )     
      {
      IndBuf_1[i]=High[i]+Vertical_Shift*Point;             // Value of 1 buffer on i bar
      price = Close[i];
      Print("Objecie bessy (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target sell: ",DoubleToString(price,Digits));
      }   
         
// spadek - gwiazda wieczorna
      if(    
         Close[i] < Open[i]
         && Close[i+2] > Open[i+2]      
         && Close[i] < (Close[i+2]-(0.5*(Close[i+2]-Open[i+2]))) //Candlestick Close is lower than 0,5 Candlestick Body
         //&& Close[i] > Open[i+2] //Candlestick Close is higher than previous Candlestick Open
         && Open[i] >= Close[i+2] //Candlestick Open is equal or higher than previous Candlestick Close
         && MathAbs(High[i+1] - Low[i+1]) < (1*MathAbs(High[i] - Low[i])) //
         && MathAbs(Open[i+1] - Close[i+1]) < (0.3*MathAbs(Open[i] - Close[i])) //
         && Low[i] > (Close[i]-(Open[i]-Close[i])) //Candlestick Low is shorter than Candlestick Body   
         && trend_down_cont == True
         && Show_GwiazdaWieczorna == True
         )  
      {
      IndBuf_1[i]=High[i]+Vertical_Shift*Point;             // Value of 1 buffer on i bar
      price = Close[i];
      Print("Gwiazda wieczorna (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target sell: ",DoubleToString(price,Digits));       
      }           
//-------------------------------------------------------------------- 
     i--;                         // Calculating index of the next bar
     }
//--------------------------------------------------------------------
   return;                          
  }