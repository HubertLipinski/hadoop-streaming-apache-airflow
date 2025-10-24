#!/usr/bin/env python3
"""
MapReduce Reducer for flights data processing.

Reads key-value pairs from stdin and aggregates:
- Key: departure_airport_id_status  
- Value: ticket_price,1

Outputs final result in format:
departure_airport_id,status,flight_count,avg_ticket_price
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
                        output_group(current_key, total_price_sum, total_flight_count)
                    
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
            output_group(current_key, total_price_sum, total_flight_count)
            
    except Exception as e:
        print(f"Fatal exception in reducer: {str(e)}", file=sys.stderr)
        sys.exit(1)

def output_group(key, total_price_sum, total_flight_count):
    """Output aggregated group in required format."""
    try:
        if '_' not in key:
            print(f"Invalid key format: {key}", file=sys.stderr)
            return
            
        # Split key into airport_id and status
        parts = key.rsplit('_', 1)
        if len(parts) != 2:
            print(f"Cannot parse key: {key}", file=sys.stderr)
            return
            
        departure_airport_id, status = parts
        
        # Calculate average ticket price
        if total_flight_count > 0:
            avg_ticket_price = total_price_sum / total_flight_count
        else:
            avg_ticket_price = 0.0
            print(f"Zero flight count for key: {key}", file=sys.stderr)
        
        # Output in required format: departure_airport_id,status,flight_count,avg_ticket_price
        print(f"{departure_airport_id},{status},{total_flight_count},{avg_ticket_price:.2f}")
        
    except Exception as e:
        print(f"Exception in output_group for key {key}: {str(e)}", file=sys.stderr)

if __name__ == "__main__":
    main()