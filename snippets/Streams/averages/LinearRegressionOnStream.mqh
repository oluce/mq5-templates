#include <Streams/AOnStream.mqh>
//LinearRegressionOnStream v1.2

class LinearRegressionOnStream : public AOnStream
{
   int _length;
   double _buffer[];
   int _offset;
public:
   LinearRegressionOnStream(IStream *source, const int length, int offset = 0)
      :AOnStream(source)
   {
      _offset = offset;
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      if (period - _offset < 0)
      {
         return false;
      }
      int size = Size();
      int index = size - 1 - period;
      if (ArrayRange(_buffer, 0) < size) 
         ArrayResize(_buffer, size);

      double price[1];
      if (!_source.GetSeriesValues(period - _offset, 1, price))
      {
         return false;
      }
      if (index < _length || _buffer[index + 1 - _length] == 0)
      {
         _buffer[index] = price[0];
         return false;
      }

      double lwmw = _length;
      double lwma = lwmw * price[0];
      double sma  = price[0];
      for (int i = 1; i < _length; ++i)
      {
         double weight = _length - i;
         lwmw += weight;
         lwma += weight * _buffer[index - i];  
         sma += _buffer[index - i];
      }
      _buffer[index] = (3.0 * lwma / lwmw - 2.0 * sma / _length);
      val = _buffer[index];
      return true;
   }
};