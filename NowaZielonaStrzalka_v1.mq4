#property indicator_chart_window    // Indicator is drawn in the main window
#property indicator_buffers 2       // Number of buffers
#property indicator_color1 Green     // Color of the 1st line
#property indicator_color2 Red      // Color of the 2nd line
 
extern int History  =120;            // Amount of bars in calculation history
extern int Bar_Index =1;             // Bar index calculated 0 = actual incompleted, 1 = last completed, 2 = second completed... 
extern int Vertical_Shift =10;             // Vertical shift of drawing in points
 
double price, csi, rsi, IndBuf_0[],IndBuf_1[], sma10_1, sma10_2, sma40_1, sma40_2;
string time;             // Declaring arrays (for indicator buffers)


//--------------------------------------------------------------------
int init()                          // Special function init()
  {
   SetIndexBuffer(0,IndBuf_0);         // Assigning an array to a buffer
   SetIndexStyle (0,DRAW_ARROW,STYLE_SOLID,1);// Arrow style
   SetIndexArrow(0,233); // Arrow code from Windigit font
   SetIndexLabel(0,"Buy");
   
   SetIndexBuffer(1,IndBuf_1);         // Assigning an array to a buffer
   SetIndexStyle (1,DRAW_ARROW,STYLE_SOLID,1);// Arrow style
   SetIndexArrow(1,234); // Arrow code from Windigit font
   SetIndexLabel(1,"Sell");
   return;                          // Exit the special funct. init()
  }
//--------------------------------------------------------------------
int start()                         // Special function start()
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
     csi = iCustom(NULL,0,"Candle Sizes",0,i); // Candle Sizes custom indicator import
     rsi = iCustom(NULL,0,"RSI",0,i); // RSI custom indicator import
     IndBuf_0[i] = 0;
     IndBuf_1[i] = 0;
     sma10_1 = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, 1); // c
     sma10_2 = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, 2); // b
     sma40_1 = iMA(NULL, 0, 40, 0, MODE_SMA, PRICE_CLOSE, 1); // d
     sma40_2 = iMA(NULL, 0, 40, 0, MODE_SMA, PRICE_CLOSE, 2); // a
// FORMACJE ----------------------------------------------------------

// wzrost - młot 30%
      if(
         MathAbs(Open[i] - Close[i]) <= (0.3*(High[i] - Low[i])) //Candlestick Body is equal or smaller than 0,3 Candlestick Range
         && csi >= 11 // Candle Sizes
         //&& rsi <= 35 // RSI below 35
         && Close[i] >= (High[i]-(0.3*(High[i] - Low[i]))) //Candlestick Close is equal or higher than 0,7 Candlestick High
         && Open[i] >= (High[i]-(0.3*(High[i] - Low[i]))) //Candlestick Open is equal or higher than 0,7 Candlestick High
        )
      {
      IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar

      Print("Formacja młota 30%, (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target buy: ",DoubleToString(price,Digits));
      //IndBuf_1[i]=High[i]+Vertical_Shift*Point;              // Value of 1st buffer on i bar  
      //ObjectCreate("data", OBJ_TEXT, 0, Time[i], High[i]);
      //ObjectSetText("data","Młotek 30%",10,"Times New Roman", Red);
      //ObjectSet("data",OBJPROP_ANGLE,50);  
      }   

// wzrost - młot 50%
      if(
         Close[i] > Open[i]
         && csi >= 11
         //&& rsi <= 35 // RSI below 35
         && MathAbs(Open[i] - Close[i]) >= (0.3*(High[i] - Low[i])) //Candlestick Body is equal or higher than 0,3 Candlestick Range
         && MathAbs(Open[i] - Close[i]) <= (0.5*(High[i] - Low[i])) //Candlestick Body is equal or smaller than 0,5 Candlestick Range
         && Close[i] >= (High[i]-(0.5*(High[i] - Low[i]))) //Candlestick Close is equal or higher than 0,5 Candlestick High
         && Open[i] >= (High[i]-(0.5*(High[i] - Low[i]))) //Candlestick Open is equal or higher than 0,5 Candlestick High
         )     
      {
      IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar
      price = Close[i];
      Print("Formacja młota 50% (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target buy: ",DoubleToString(price,Digits));
      }
      
//spadek - spadajaca gwiazda / odwrócony młot      
      if(
         MathAbs(Open[i] - Close[i]) <= (0.3*(High[i] - Low[i])) //Candlestick Body is equal or smaller than 0,3 Candlestick Range
         && csi >= 11 // Candle Sizes
         //&& rsi >= 65 // RSI over 65
         && Close[i] <= (Low[i]+(0.3*(High[i] - Low[i]))) //Candlestick Close is equal or smaller than 0,3 Candlestick Low
         && Open[i] <= (Low[i]+(0.3*(High[i] - Low[i]))) //Candlestick Open is equal or smaller than 0,3 Candlestick Low
        )
      {
      IndBuf_1[i]=High[i]+Vertical_Shift*Point;             // Value of 0 buffer on i bar
      price = Close[i];
      Print("Formacja spadającej gwiazdy 30% (",time,") - CSI: ",csi,", RSI: ",DoubleToString(rsi,Digits),", Target buy: ",DoubleToString(price,Digits));
      //IndBuf_1[i]=High[i]+Vertical_Shift*Point;              // Value of 1st buffer on i bar  
      //ObjectCreate("data", OBJ_TEXT, 0, Time[i], High[i]);
      //ObjectSetText("data","Młotek 30%",10,"Times New Roman", Red);
      //ObjectSet("data",OBJPROP_ANGLE,50);  
      }   
      
//-------------------------------------------------------------------- 
     i--;                         // Calculating index of the next bar
     }
//--------------------------------------------------------------------
   return;                          // Exit the special funct. start()
  }