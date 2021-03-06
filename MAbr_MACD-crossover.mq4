#property indicator_chart_window    // Indicator is drawn in the main window
#property indicator_buffers 2       // Number of buffers for signals
#property indicator_color1 Aqua    // Color of BUY signal
#property indicator_color2 Magenta      // Color of SELL signal

//adjust visuals
input int Vertical_Shift = 10;       // Vertical shift of drawing in points 
input int History  = 480;            // Amount of bars in calculation history
input int Bar_Index = 1;             // Bar index calculated 0 = actual incompleted, 1 = last completed, 2 = second completed... 


//adjust aux parameters for trade with/against trend
input int SlowMA_period = 200;
input int Distance = 1;


double IndBuf_0[],IndBuf_1[];       // Declaring arrays for indicator buffers
double price, ma_faster, ma_slower, macd_main_prev, macd_main_actual, macd_signal_prev, macd_signal_actual; // Declaring aux variables for indicator strategy
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

     ma_slower = iMA(NULL, 0, SlowMA_period, 0, MODE_EMA, PRICE_CLOSE, i);
     
     macd_main_prev = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i+Distance);
     macd_main_actual = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i);
     macd_signal_prev = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, i+Distance);
     macd_signal_actual = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, i);
     

             
// CANDLE PATTERNS ----------------------------------------------------------

// BUY signal: MACD main crossover up MACD singal below Zero line & Closing Price over EMA200
      if( 
         macd_main_prev < macd_signal_prev
         && macd_main_actual >= macd_signal_actual
         && macd_main_prev < 0
         && macd_main_actual < 0
         && macd_signal_prev < 0
         && macd_signal_actual < 0
         && Low[i] > ma_slower  
        )
      {
      IndBuf_0[i]=Low[i]-Vertical_Shift*Point;             // Value of 0 buffer on i bar
      //Print(Symbol(), Period(), " BUY Signal ",time,
      //": macd_main_actual = ", DoubleToString(macd_main_actual, Digits+1),
      //", macd_signal_actual = ", DoubleToString(macd_signal_actual, Digits+1),
      //", macd_main_prev = ", DoubleToString(macd_main_prev, Digits+1),
      //", macd_signal_prev = ", DoubleToString(macd_signal_prev, Digits+1),
      //", Low[1] = ", DoubleToString(Low[1], Digits+1),
      //", ma_slower = ", DoubleToString(ma_slower, Digits+1));
      //Alert(Symbol(), Period(), " BUY Signal ",time,": MACD main actual: ", macd_main_actual,", MACD signal actual: ", macd_signal_actual,", Close: ", price);
      
      //IndBuf_1[i]=High[i]+Vertical_Shift*Point;              // Value of 1st buffer on i bar  
      //ObjectCreate("data", OBJ_TEXT, 0, Time[i], High[i]);
      //ObjectSetText("data","Młotek 30%",10,"Times New Roman", Red);
      //ObjectSet("data",OBJPROP_ANGLE,50);  
      }   

    
//SELL signal: MACD main crossover down MACD singal over Zero line & Closing Price under EMA200    
      if(
         macd_main_prev > macd_signal_prev
         && macd_main_actual <= macd_signal_actual
         && macd_main_prev > 0
         && macd_main_actual > 0
         && macd_signal_prev > 0
         && macd_signal_actual > 0
         && High[i] < ma_slower  
        )
      {
      IndBuf_1[i]=High[i]+Vertical_Shift*Point;             // Value of 1 buffer on i bar
      //Print(Symbol(), Period(), " SELL Signal ",
      //time,
      //": macd_main_actual = ", DoubleToString(macd_main_actual, Digits+1),
      //", macd_signal_actual = ", DoubleToString(macd_signal_actual, Digits+1),
      //", macd_main_prev = ", DoubleToString(macd_main_prev, Digits+1),
      //", macd_signal_prev = ", DoubleToString(macd_signal_prev, Digits+1),
      //", High[1] = ", DoubleToString(High[1], Digits+1),
      //", ma_slower = ", DoubleToString(ma_slower, Digits+1));
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