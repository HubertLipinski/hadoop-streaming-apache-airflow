#!/usr/bin/env python3
"""
MapReduce Combiner for flights data processing.

Performs local aggregation of mapper output to reduce network traffic.
For average calculation, aggregates price sums and counts locally.

Input/Output format:
- Key: departure_airport_id_status  
- Value: price_sum,count
"""

import sys

def main():
    current_key = None
    total_price_sum = 0.0
    total_flight_count = 0
    
    try:
        for line_num, line in enumerate(sys.stdin, 1):
            line = line.strip()
            
            if not line:
                continue
                
            try:
                if '\t' not in line:
                    print(f"No tab separator in line {line_num}: {line}", file=sys.stderr)
                    continue
                    
                key, value = line.split('\t', 1)
                
                if ',' not in value:
                    print(f"Invalid value format in line {line_num}: {value}", file=sys.stderr)
                    continue
                    
                price_str, count_str = value.split(',', 1)
                
                try:
                    price = float(price_str)
                    count = int(count_str)
                except ValueError as e:
                    print(f"Invalid number format in line {line_num}: {e}", file=sys.stderr)
                    continue
                
                if current_key != key:
                    if current_key is not None:
                        output_partial_aggregation(current_key, total_price_sum, total_flight_count)
                    
                    current_key = key
                    total_price_sum = price
                    total_flight_count = count
                else:
                    total_price_sum += price
                    total_flight_count += count
                    
            except Exception as e:
                print(f"Exception processing line {line_num}: {str(e)}", file=sys.stderr)
                continue
        
        if current_key is not None:
            output_partial_aggregation(current_key, total_price_sum, total_flight_count)
            
    except Exception as e:
        print(f"Fatal exception in combiner: {str(e)}", file=sys.stderr)
        sys.exit(1)

def output_partial_aggregation(key, total_price_sum, total_flight_count):
    """Output partial aggregation in the same format as mapper output."""
    try:
        print(f"{key}\t{total_price_sum},{total_flight_count}")
    except Exception as e:
        print(f"Exception in output_partial_aggregation for key {key}: {str(e)}", file=sys.stderr)

if __name__ == "__main__":
    main()