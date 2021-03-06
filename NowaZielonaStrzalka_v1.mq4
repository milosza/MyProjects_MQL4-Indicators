#property indicator_chart_window    // Indicator is drawn in the main window
#property indicator_buffers 2       // Number of buffers for signals
#property indicator_color1 Green    // Color of BUY signal
#property indicator_color2 Red      // Color of SELL signal

//adjust visuals
input int Vertical_Shift = 10;       // Vertical shift of drawing in points 
input int History  = 40320;            // Amount of bars in calculation history
input int Bar_Index = 1;             // Bar index calculated 0 = actual incompleted, 1 = last completed, 2 = second completed... 

//show patterns
input bool Show_Mlot = True; // Show Hammer pattern
input bool Show_SpadajacaGwiazda = True;
input bool Show_Przenikanie = True;
input bool Show_ZaslonaCiemnejChmury = True;
input bool Show_ObjecieHossy = True;
input bool Show_ObjecieBessy = True;
input bool Show_GwiazdaPolarna = True;
input bool Show_GwiazdaWieczorna = True;

//adjust importance of signal
input int CSI_number = 11; // Candle Sizes indicator bigger than 11

//trade with/agaainst patterns' trend, e.g. trade hammer on bearish trend
input bool Trade_All = False;
input bool Trade_WithTrend_Only = True;
input bool Trade_AgainstTrend_Only = False;

//adjust aux parameters for trade with/against trend
input int RSI_top_level = 65;
input int RSI_bottom_level = 35;
input int FastMA_period = 21;
input int SlowMA_period = 100;
input int Distance = 3;



double IndBuf_0[],IndBuf_1[];       // Declaring arrays for indicator buffers
double price, csi, rsi, ma_faster, ma_faster_prev, ma_slower; // Declaring aux variables for indicator strategy
bool trend_up_cont, trend_down_cont, trend_up_break, trend_down_break;
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
   return(0);                          
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
     
     csi = NormalizeDouble(iCustom(NULL,0,"Candle Sizes",0,i), Digits); // Candle Sizes custom indicator import
     rsi = NormalizeDouble(iCustom(NULL,0,"RSI",0,i), Digits); // RSI custom indicator import
     ma_faster = NormalizeDouble(iMA(NULL, 0, FastMA_period, 0, MODE_EMA, PRICE_CLOSE, i), Digits);
     ma_faster_prev = NormalizeDouble(iMA(NULL, 0, FastMA_period, 0, MODE_EMA, PRICE_CLOSE, i+Distance), Digits);
     ma_slower = NormalizeDouble(iMA(NULL, 0, SlowMA_period, 0, MODE_EMA, PRICE_CLOSE, i), Digits);
     
// BUY/SELL PRIMARY CONDITIONS ----------------------------------------------

//buy
      if(
         rsi <= RSI_top_level // RSI below 65 
         //&& price > ma_slower 
         && ma_faster_prev < ma_faster  
        ) trend_up_cont = True;
        else trend_up_cont = False;              
      if(
         rsi <= RSI_bottom_level // RSI below 35 
         //&& price < ma_slower 
         && ma_faster_prev < ma_faster
        ) trend_down_break = True;
        else trend_down_break = False; 
//sell
      if(
         rsi >= RSI_bottom_level // RSI over 35   
         //&& price < ma_slower 
         && ma_faster_prev > ma_faster        
        ) trend_down_cont = True;
        else trend_down_cont = False;  
        
      if(
         rsi >= RSI_top_level // RSI over 65
         //&& price > ma_slower
         && ma_faster_prev > ma_faster
        ) trend_up_break = True;
        else trend_up_break = False;   
             
// CANDLE PATTERNS ----------------------------------------------------------

// wzrost - młot 30%
      if(
            (MathAbs(Open[i] - Close[i]) <= (0.3*(High[i] - Low[i])) //Candlestick Body is equal or smaller than 0,3 Candlestick Range
            && Close[i] >= (High[i]-(0.3*(High[i] - Low[i]))) //Candlestick Close is equal or higher than 0,7 Candlestick High
            && Open[i] >= (High[i]-(0.3*(High[i] - Low[i]))) //Candlestick Open is equal or higher than 0,7 Candlestick High
            && Show_Mlot == True
            && csi >= CSI_number)
         &&
            (Trade_All == True ||
             (Trade_WithTrend_Only == True && trend_up_cont == True) || 
             (Trade_AgainstTrend_Only == True && trend_down_break == True)
            )
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
            (Close[i] > Open[i]     
            && MathAbs(Open[i] - Close[i]) >= (0.3*(High[i] - Low[i])) //Candlestick Body is equal or higher than 0,3 Candlestick Range
            && MathAbs(Open[i] - Close[i]) <= (0.5*(High[i] - Low[i])) //Candlestick Body is equal or smaller than 0,5 Candlestick Range
            && Close[i] >= (High[i]-(0.5*(High[i] - Low[i]))) //Candlestick Close is equal or higher than 0,5 Candlestick High
            && Open[i] >= (High[i]-(0.5*(High[i] - Low[i]))) //Candlestick Open is equal or higher than 0,5 Candlestick High
            && Show_Mlot == True
            && csi >= CSI_number)
         && 
            (Trade_All == True ||
             (Trade_WithTrend_Only == True && trend_up_cont == True) || 
             (Trade_AgainstTrend_Only == True && trend_down_break == True)
            )
         )     
       {
       IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar
       price = Close[i];
       Print("Młot 50% (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target buy: ",DoubleToString(price,Digits));
       }

// wzrost - przenikanie
      if(
            (Close[i] > Open[i]
            && Open[i+1] > Close[i+1]     
            && Close[i] > (Open[i+1]-(0.5*(Open[i+1] - Close[i+1]))) //Candlestick Close is higher than 0,5 Candlestick Body
            && Close[i] < Open[i+1] //Candlestick Close is lower than previous Candlestick Open
            && Open[i] <= Close[i+1] //Candlestick Open is equal or lower than previous Candlestick Close
            && High[i] < (Close[i]+(0.3*(Close[i]-Open[i]))) //Candlestick High is shorter than Candlestick Body
            && Low[i] > (Open[i]-(0.3*(Close[i]-Open[i]))) //Candlestick Low is shorter than Candlestick Body
            && Show_Przenikanie == True
            && csi >= CSI_number)
         &&
            (Trade_All == True ||
             (Trade_WithTrend_Only == True && trend_up_cont == True) || 
             (Trade_AgainstTrend_Only == True && trend_down_break == True)
            )
         )     
      {
      IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar
      price = Close[i];
      Print("Przenikanie (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target buy: ",DoubleToString(price,Digits));
      }
      
// wzrost - objecie hossy
      if(
            (Close[i] > Open[i]
            && Open[i+1] > Close[i+1]     
            && Open[i] <= Close[i+1] //Candlestick Open is lower than previous Candlestick Close
            && Close[i] >= Open[i+1] //Candlestick Close is higher than previous Candlestick Open
            && High[i] < (Close[i]+(0.3*(Close[i]-Open[i]))) //Candlestick High is shorter than Candlestick Body
            && Low[i] > (Open[i]-(0.3*(Close[i]-Open[i]))) //Candlestick Low is shorter than Candlestick Body
            //&& (Open[i+1]-Close[i+1]) > (0.6*(Close[i]-Open[i])) //previous candle body similar to actual candle
            && Show_ObjecieHossy == True
            && csi >= CSI_number)
         && 
            (Trade_All == True ||
             (Trade_WithTrend_Only == True && trend_up_cont == True) || 
             (Trade_AgainstTrend_Only == True && trend_down_break == True)
            )
         )     
      {
      IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar
      price = Close[i];
      Print("Objecie hossy (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target buy: ",DoubleToString(price,Digits));
      }

// wzrost - gwiazda poranna
      if(
            (Close[i] > Open[i]
            && Open[i+2] > Close[i+2]     
            && Close[i] > (Open[i+2]-(0.5*(Open[i+2] - Close[i+2]))) //Candlestick Close is higher than 0,5 Candlestick Body
            //&& Close[i] < Open[i+2] //Candlestick Close is lower than previous Candlestick Open
            && Open[i] <= Close[i+2] //Candlestick Open is equal or lower than previous Candlestick Close
            && MathAbs(High[i+1] - Low[i+1]) < (1*MathAbs(High[i] - Low[i])) //
            && MathAbs(Open[i+1] - Close[i+1]) < (0.3*MathAbs(Open[i] - Close[i])) //
            && High[i] < (Close[i]+(Close[i]-Open[i])) //Candlestick High is shorter than Candlestick Body
            && Low[i] > (Open[i]-(0.3*(Close[i]-Open[i]))) //Candlestick Low is shorter than Candlestick Body
            && Show_GwiazdaPolarna == True
            && csi >= CSI_number)
         && 
            (Trade_All == True ||
             (Trade_WithTrend_Only == True && trend_up_cont == True) || 
             (Trade_AgainstTrend_Only == True && trend_down_break == True)
            )   
         )     
      {
      IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar
      price = Close[i];
      Print("Gwiazda polarna (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target buy: ",DoubleToString(price,Digits));
      }
     
//spadek - spadajaca gwiazda 30% / odwrócony młot      
      if(
            (MathAbs(Open[i] - Close[i]) <= (0.3*(High[i] - Low[i])) //Candlestick Body is equal or smaller than 0,3 Candlestick Range
            && Close[i] <= (Low[i]+(0.3*(High[i] - Low[i]))) //Candlestick Close is equal or smaller than 0,3 Candlestick Low
            && Open[i] <= (Low[i]+(0.3*(High[i] - Low[i]))) //Candlestick Open is equal or smaller than 0,3 Candlestick Low
            && Show_SpadajacaGwiazda == True
            && csi >= CSI_number)
         && 
            (Trade_All == True ||
             (Trade_WithTrend_Only == True && trend_down_cont == True) || 
             (Trade_AgainstTrend_Only == True && trend_up_break == True)
            )
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
            (Close[i] < Open[i]     
            && MathAbs(Open[i] - Close[i]) >= (0.3*(High[i] - Low[i])) //Candlestick Body is equal or higher than 0,3 Candlestick Range
            && MathAbs(Open[i] - Close[i]) <= (0.5*(High[i] - Low[i])) //Candlestick Body is equal or smaller than 0,5 Candlestick Range
            && Close[i] <= (Low[i]+(0.5*(High[i] - Low[i]))) //Candlestick Close is equal or smaller than 0,5 Candlestick Low
            && Open[i] <= (Low[i]+(0.5*(High[i] - Low[i]))) //Candlestick Open is equal or smaller than 0,5 Candlestick Low
            && Show_SpadajacaGwiazda == True
            && csi >= CSI_number)
         && 
            (Trade_All == True ||
             (Trade_WithTrend_Only == True && trend_down_cont == True) || 
             (Trade_AgainstTrend_Only == True && trend_up_break == True)
            )
        )
      {
      IndBuf_1[i]=High[i]+Vertical_Shift*Point;             // Value of 1 buffer on i bar
      price = Close[i];
      Print("Spadająca gwiazda 50% (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target sell: ",DoubleToString(price,Digits));  
      }  

// spadek - zasłona ciemnej
      if(
            (Close[i] < Open[i]
            && Close[i+1] > Open[i+1]      
            && Close[i] < (Close[i+1]-(0.5*(Close[i+1]-Open[i+1]))) //Candlestick Close is lower than 0,5 Candlestick Body
            && Close[i] > Open[i+1] //Candlestick Close is higher than previous Candlestick Open
            && Open[i] >= Close[i+1] //Candlestick Open is equal or higher than previous Candlestick Close
            && Low[i] > (Close[i]-(0.3*(Open[i]-Close[i]))) //Candlestick Low is shorter than Candlestick Body
            && High[i] < (Open[i]+(0.3*(Open[i]-Close[i]))) //Candlestick High is shorter than Candlestick Body      
            && Show_ZaslonaCiemnejChmury == True
            && csi >= CSI_number)
         && 
            (Trade_All == True ||
             (Trade_WithTrend_Only == True && trend_down_cont == True) || 
             (Trade_AgainstTrend_Only == True && trend_up_break == True)
            )
         )  
      {
      IndBuf_1[i]=High[i]+Vertical_Shift*Point;             // Value of 1 buffer on i bar
      price = Close[i];
      Print("Zasłona ciemnej chmury (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target sell: ",DoubleToString(price,Digits));       
      } 
      
// spadek - objecie bessy
      if(
            (Close[i] < Open[i]
            && Open[i+1] < Close[i+1]     
            && Close[i] <= Open[i+1] //Candlestick Close is lower than previous Candlestick Open
            && Open[i] >= Close[i+1] //Candlestick Open is higher than previous Candlestick Close
            && Low[i] > (Close[i]-(0.3*(Open[i]-Close[i]))) //Candlestick Low is shorter than Candlestick Body   
            && High[i] < (Open[i]+(0.3*(Open[i]-Close[i]))) //Candlestick High is shorter than Candlestick Body   
            //&& (Open[i+1]-Close[i+1]) > (0.6*(Close[i]-Open[i])) //previous candle body similar to actual candle
            && Show_ObjecieBessy == True
            && csi >= CSI_number)
         && 
            (Trade_All == True ||
             (Trade_WithTrend_Only == True && trend_down_cont == True) || 
             (Trade_AgainstTrend_Only == True && trend_up_break == True)
            )
         )     
      {
      IndBuf_1[i]=High[i]+Vertical_Shift*Point;             // Value of 1 buffer on i bar
      price = Close[i];
      Print("Objecie bessy (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target sell: ",DoubleToString(price,Digits));
      }   
         
// spadek - gwiazda wieczorna
      if(    
            (Close[i] < Open[i]
            && Close[i+2] > Open[i+2]      
            && Close[i] < (Close[i+2]-(0.5*(Close[i+2]-Open[i+2]))) //Candlestick Close is lower than 0,5 Candlestick Body
            //&& Close[i] > Open[i+2] //Candlestick Close is higher than previous Candlestick Open
            && Open[i] >= Close[i+2] //Candlestick Open is equal or higher than previous Candlestick Close
            && MathAbs(High[i+1] - Low[i+1]) < (1*MathAbs(High[i] - Low[i])) //
            && MathAbs(Open[i+1] - Close[i+1]) < (0.3*MathAbs(Open[i] - Close[i])) //
            && Low[i] > (Close[i]-(Open[i]-Close[i])) //Candlestick Low is shorter than Candlestick Body 
            && High[i] < (Open[i]+(0.3*(Open[i]-Close[i]))) //Candlestick High is shorter than Candlestick Body     
            && Show_GwiazdaWieczorna == True
            && csi >= CSI_number)
         && 
            (Trade_All == True ||
             (Trade_WithTrend_Only == True && trend_down_cont == True) || 
             (Trade_AgainstTrend_Only == True && trend_up_break == True)
            )
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
   return(0);                          
  }