#property indicator_chart_window    // Indicator is drawn in the main window
#property indicator_buffers 2       // Number of buffers for signals
#property indicator_color1 Aqua    // Color of BUY signal
#property indicator_color2 Magenta      // Color of SELL signal

//adjust visuals
input int Vertical_Shift = 10;       // Vertical shift of drawing in points 
input int History  = 4800;            // Amount of bars in calculation history
input int Bar_Index = 1;             // Bar index calculated 0 = actual incompleted, 1 = last completed, 2 = second completed... 


//adjust aux parameters for trade with/against trend
input int FastMA_period = 21;
input int SlowMA_period = 200;
input int Distance = 1;


double IndBuf_0[],IndBuf_1[];       // Declaring arrays for indicator buffers
double price, ema_faster_prev, ema_faster_actual, ema_slower_prev, ema_slower_actual; // Declaring aux variables for indicator strategy
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
     
     ema_faster_actual = NormalizeDouble(iMA(NULL, 0, FastMA_period, 0, MODE_EMA, PRICE_CLOSE, i), Digits);
     ema_faster_prev = NormalizeDouble(iMA(NULL, 0, FastMA_period, 0, MODE_EMA, PRICE_CLOSE, i+Distance), Digits);
     ema_slower_actual = NormalizeDouble(iMA(NULL, 0, SlowMA_period, 0, MODE_EMA, PRICE_CLOSE, i), Digits);
     ema_slower_prev = NormalizeDouble(iMA(NULL, 0, SlowMA_period, 0, MODE_EMA, PRICE_CLOSE, i+Distance), Digits);
     
     Print(time,
           ", ema_faster_actual: ", DoubleToStr(ema_faster_actual,8),
           ", ema_slower_actual: ", DoubleToStr(ema_slower_actual,8),
           ", ema_faster_prev: ", DoubleToStr(ema_faster_prev,8),
           ", ema_slower_prev: ", DoubleToStr(ema_slower_prev,8)
           );
             
// CANDLE PATTERNS ----------------------------------------------------------

// BUY signal: 
      if( 
         ema_faster_prev <= ema_slower_prev
         && ema_faster_actual > ema_slower_actual
         && Low[1] > ema_slower_actual
         //&& ema_slower_actual > ema_slower_prev
        )
      {
      IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar
      Print("BUY Signal ",time);
      //Alert(Symbol(), Period(), " BUY Signal ",time,": MACD main actual: ", macd_main_actual,", MACD signal actual: ", macd_signal_actual,", Close: ", price);
      
      //IndBuf_1[i]=High[i]+Vertical_Shift*Point;              // Value of 1st buffer on i bar  
      //ObjectCreate("data", OBJ_TEXT, 0, Time[i], High[i]);
      //ObjectSetText("data","Młotek 30%",10,"Times New Roman", Red);
      //ObjectSet("data",OBJPROP_ANGLE,50);  
      }   

    
//SELL signal:   
      if(
         ema_faster_prev >= ema_slower_prev 
         && ema_faster_actual < ema_slower_actual
         && High[1] < ema_slower_actual
         //&& ema_slower_actual < ema_slower_prev  
        )
      {
      IndBuf_1[i]=High[i]+Vertical_Shift*Point;             // Value of 1 buffer on i bar
      Print("SELL Signal ",time);
      //Alert(Symbol(), Period(), " SELL Signal ",time,": MACD main actual: ", macd_main_actual,", MACD signal actual: ", macd_signal_actual,", Close: ", price);
      
      //IndBuf_1[i]=High[i]+Vertical_Shift*Point;              // Value of 1st buffer on i bar  
      //ObjectCreate("data", OBJ_TEXT, 0, Time[i], High[i]);
      //ObjectSetText("data","Młotek 30%",10,"Times New Roman", Red);
      //ObjectSet("data",OBJPROP_ANGLE,50);  
      }   
    
//-------------------------------------------------------------------- 
     i--;                         // Calculating index of the next bar
     }
//--------------------------------------------------------------------
   return(0);                          
  }