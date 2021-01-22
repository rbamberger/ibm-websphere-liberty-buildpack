# frozen_string_literal: true

# IBM WebSphere Application Server Liberty Buildpack
# Copyright IBM Corp. 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative 'memory_range'

# A MemoryBucket is used to calculate default sizes for various type of memory
class MemoryBucket

  # @!attribute [r] size
  # @return [Numeric, nil] the size of the memory bucket in KB or nil if this has not been specified by the user or
  #                        defaulted
  attr_accessor :size

  # @!attribute [r] range
  # @return [MemoryRange] the permissible range of the memory bucket
  attr_accessor :range

  # @!attribute [r] weighting
  # @return [Numeric] the weighting of the memory bucket
  attr_reader :weighting

  # Constructs a memory bucket.
  #
  # @param [String] name a non-empty, human-readable name for this memory bucket, used only in diagnostics
  # @param [Numeric] weighting a number between 0 and 1 corresponding to the proportion of total memory which this
  #                  memory bucket should consume by default
  # @param [MemoryRange, nil] range a user-specified range for the memory bucket or nil if the user did not specify a
  #                            range
  def initialize(name, weighting, range)
    @name      = validate_name name
    @weighting = validate_weighting weighting
    @range     = range ? validate_memory_range(range) : nil
  end

  private

  def validate_name(name)
    raise "Invalid MemoryBucket name '#{name}'" if name.nil? || name.to_s.size == 0

    name
  end

  def validate_weighting(weighting)
    raise diagnose_weighting(weighting, 'not numeric') unless numeric? weighting
    raise diagnose_weighting(weighting, 'negative') if weighting < 0

    weighting
  end

  def diagnose_weighting(weighting, reason)
    "Invalid weighting '#{weighting}' for #{identify} : #{reason}"
  end

  def numeric?(w)
    Float(w)
  rescue StandardError
    false
  end

  def identify
    "MemoryBucket #{@name}"
  end

  def validate_memory_range(range)
    raise "Invalid 'range' parameter of class '#{range.class}' for #{identify} : not a MemoryRange" unless range.is_a? MemoryRange

    range
  end

end
