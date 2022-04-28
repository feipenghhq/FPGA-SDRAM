package require -exact qsys 12.1

# module properties
set_module_property NAME {de2_export}
set_module_property DISPLAY_NAME {de2_export_display}

# default module properties
set_module_property VERSION {1.0}
set_module_property GROUP {default group}
set_module_property DESCRIPTION {default description}
set_module_property AUTHOR {author}

# Instances and instance parameters
# (disabled instances are intentionally culled)
add_instance clk clock_source 13.0
set_instance_parameter_value clk clockFrequency {50000000.0}
set_instance_parameter_value clk clockFrequencyKnown {1}
set_instance_parameter_value clk resetSynchronousEdges {NONE}

add_instance cpu altera_nios2_qsys 13.0
set_instance_parameter_value cpu setting_showUnpublishedSettings {0}
set_instance_parameter_value cpu setting_showInternalSettings {0}
set_instance_parameter_value cpu setting_preciseSlaveAccessErrorException {0}
set_instance_parameter_value cpu setting_preciseIllegalMemAccessException {0}
set_instance_parameter_value cpu setting_preciseDivisionErrorException {0}
set_instance_parameter_value cpu setting_performanceCounter {0}
set_instance_parameter_value cpu setting_illegalMemAccessDetection {0}
set_instance_parameter_value cpu setting_illegalInstructionsTrap {0}
set_instance_parameter_value cpu setting_fullWaveformSignals {0}
set_instance_parameter_value cpu setting_extraExceptionInfo {0}
set_instance_parameter_value cpu setting_exportPCB {0}
set_instance_parameter_value cpu setting_debugSimGen {0}
set_instance_parameter_value cpu setting_clearXBitsLDNonBypass {1}
set_instance_parameter_value cpu setting_bit31BypassDCache {1}
set_instance_parameter_value cpu setting_bigEndian {0}
set_instance_parameter_value cpu setting_export_large_RAMs {0}
set_instance_parameter_value cpu setting_asic_enabled {0}
set_instance_parameter_value cpu setting_asic_synopsys_translate_on_off {0}
set_instance_parameter_value cpu setting_oci_export_jtag_signals {0}
set_instance_parameter_value cpu setting_bhtIndexPcOnly {0}
set_instance_parameter_value cpu setting_avalonDebugPortPresent {0}
set_instance_parameter_value cpu setting_alwaysEncrypt {1}
set_instance_parameter_value cpu setting_allowFullAddressRange {0}
set_instance_parameter_value cpu setting_activateTrace {1}
set_instance_parameter_value cpu setting_activateTestEndChecker {0}
set_instance_parameter_value cpu setting_activateMonitors {1}
set_instance_parameter_value cpu setting_activateModelChecker {0}
set_instance_parameter_value cpu setting_HDLSimCachesCleared {1}
set_instance_parameter_value cpu setting_HBreakTest {0}
set_instance_parameter_value cpu muldiv_divider {0}
set_instance_parameter_value cpu mpu_useLimit {0}
set_instance_parameter_value cpu mpu_enabled {0}
set_instance_parameter_value cpu mmu_enabled {0}
set_instance_parameter_value cpu mmu_autoAssignTlbPtrSz {1}
set_instance_parameter_value cpu manuallyAssignCpuID {1}
set_instance_parameter_value cpu debug_triggerArming {1}
set_instance_parameter_value cpu debug_embeddedPLL {1}
set_instance_parameter_value cpu debug_debugReqSignals {0}
set_instance_parameter_value cpu debug_assignJtagInstanceID {0}
set_instance_parameter_value cpu dcache_omitDataMaster {0}
set_instance_parameter_value cpu cpuReset {0}
set_instance_parameter_value cpu is_hardcopy_compatible {0}
set_instance_parameter_value cpu setting_shadowRegisterSets {0}
set_instance_parameter_value cpu mpu_numOfInstRegion {8}
set_instance_parameter_value cpu mpu_numOfDataRegion {8}
set_instance_parameter_value cpu mmu_TLBMissExcOffset {0}
set_instance_parameter_value cpu debug_jtagInstanceID {0}
set_instance_parameter_value cpu resetOffset {0}
set_instance_parameter_value cpu exceptionOffset {32}
set_instance_parameter_value cpu cpuID {0}
set_instance_parameter_value cpu cpuID_stored {0}
set_instance_parameter_value cpu breakOffset {32}
set_instance_parameter_value cpu userDefinedSettings {}
set_instance_parameter_value cpu resetSlave {new_sdram_controller_0.s1}
set_instance_parameter_value cpu mmu_TLBMissExcSlave {None}
set_instance_parameter_value cpu exceptionSlave {new_sdram_controller_0.s1}
set_instance_parameter_value cpu breakSlave {cpu.jtag_debug_module}
set_instance_parameter_value cpu setting_perfCounterWidth {32}
set_instance_parameter_value cpu setting_interruptControllerType {Internal}
set_instance_parameter_value cpu setting_branchPredictionType {Automatic}
set_instance_parameter_value cpu setting_bhtPtrSz {8}
set_instance_parameter_value cpu muldiv_multiplierType {EmbeddedMulFast}
set_instance_parameter_value cpu mpu_minInstRegionSize {12}
set_instance_parameter_value cpu mpu_minDataRegionSize {12}
set_instance_parameter_value cpu mmu_uitlbNumEntries {4}
set_instance_parameter_value cpu mmu_udtlbNumEntries {6}
set_instance_parameter_value cpu mmu_tlbPtrSz {7}
set_instance_parameter_value cpu mmu_tlbNumWays {16}
set_instance_parameter_value cpu mmu_processIDNumBits {8}
set_instance_parameter_value cpu impl {Tiny}
set_instance_parameter_value cpu icache_size {4096}
set_instance_parameter_value cpu icache_tagramBlockType {Automatic}
set_instance_parameter_value cpu icache_ramBlockType {Automatic}
set_instance_parameter_value cpu icache_numTCIM {0}
set_instance_parameter_value cpu icache_burstType {None}
set_instance_parameter_value cpu dcache_bursts {false}
set_instance_parameter_value cpu dcache_victim_buf_impl {ram}
set_instance_parameter_value cpu debug_level {Level1}
set_instance_parameter_value cpu debug_OCIOnchipTrace {_128}
set_instance_parameter_value cpu dcache_size {2048}
set_instance_parameter_value cpu dcache_tagramBlockType {Automatic}
set_instance_parameter_value cpu dcache_ramBlockType {Automatic}
set_instance_parameter_value cpu dcache_numTCDM {0}
set_instance_parameter_value cpu dcache_lineSize {32}
set_instance_parameter_value cpu setting_exportvectors {0}
set_instance_parameter_value cpu setting_ecc_present {0}
set_instance_parameter_value cpu regfile_ramBlockType {Automatic}
set_instance_parameter_value cpu ocimem_ramBlockType {Automatic}
set_instance_parameter_value cpu mmu_ramBlockType {Automatic}
set_instance_parameter_value cpu bht_ramBlockType {Automatic}

add_instance jtag_uart_0 altera_avalon_jtag_uart 13.0.1.99.2
set_instance_parameter_value jtag_uart_0 allowMultipleConnections {0}
set_instance_parameter_value jtag_uart_0 hubInstanceID {0}
set_instance_parameter_value jtag_uart_0 readBufferDepth {64}
set_instance_parameter_value jtag_uart_0 readIRQThreshold {8}
set_instance_parameter_value jtag_uart_0 simInputCharacterStream {}
set_instance_parameter_value jtag_uart_0 simInteractiveOptions {NO_INTERACTIVE_WINDOWS}
set_instance_parameter_value jtag_uart_0 useRegistersForReadBuffer {0}
set_instance_parameter_value jtag_uart_0 useRegistersForWriteBuffer {0}
set_instance_parameter_value jtag_uart_0 useRelativePathForSimFile {0}
set_instance_parameter_value jtag_uart_0 writeBufferDepth {64}
set_instance_parameter_value jtag_uart_0 writeIRQThreshold {8}

add_instance new_sdram_controller_0 altera_avalon_new_sdram_controller 13.0.1.99.2
set_instance_parameter_value new_sdram_controller_0 TAC {5.5}
set_instance_parameter_value new_sdram_controller_0 TRCD {20.0}
set_instance_parameter_value new_sdram_controller_0 TRFC {70.0}
set_instance_parameter_value new_sdram_controller_0 TRP {20.0}
set_instance_parameter_value new_sdram_controller_0 TWR {14.0}
set_instance_parameter_value new_sdram_controller_0 casLatency {3}
set_instance_parameter_value new_sdram_controller_0 columnWidth {8}
set_instance_parameter_value new_sdram_controller_0 dataWidth {32}
set_instance_parameter_value new_sdram_controller_0 generateSimulationModel {0}
set_instance_parameter_value new_sdram_controller_0 initRefreshCommands {2}
set_instance_parameter_value new_sdram_controller_0 model {single_Micron_MT48LC4M32B2_7_chip}
set_instance_parameter_value new_sdram_controller_0 numberOfBanks {4}
set_instance_parameter_value new_sdram_controller_0 numberOfChipSelects {1}
set_instance_parameter_value new_sdram_controller_0 pinsSharedViaTriState {0}
set_instance_parameter_value new_sdram_controller_0 powerUpDelay {100.0}
set_instance_parameter_value new_sdram_controller_0 refreshPeriod {15.625}
set_instance_parameter_value new_sdram_controller_0 rowWidth {12}
set_instance_parameter_value new_sdram_controller_0 masteredTristateBridgeSlave {0}
set_instance_parameter_value new_sdram_controller_0 TMRD {3.0}
set_instance_parameter_value new_sdram_controller_0 initNOPDelay {0.0}
set_instance_parameter_value new_sdram_controller_0 registerDataIn {1}

# connections and connection parameters
add_connection cpu.instruction_master cpu.jtag_debug_module avalon
set_connection_parameter_value cpu.instruction_master/cpu.jtag_debug_module arbitrationPriority {1}
set_connection_parameter_value cpu.instruction_master/cpu.jtag_debug_module baseAddress {0x02000800}
set_connection_parameter_value cpu.instruction_master/cpu.jtag_debug_module defaultConnection {0}

add_connection cpu.data_master cpu.jtag_debug_module avalon
set_connection_parameter_value cpu.data_master/cpu.jtag_debug_module arbitrationPriority {1}
set_connection_parameter_value cpu.data_master/cpu.jtag_debug_module baseAddress {0x02000800}
set_connection_parameter_value cpu.data_master/cpu.jtag_debug_module defaultConnection {0}

add_connection cpu.jtag_debug_module_reset clk.clk_in_reset reset

add_connection clk.clk_reset cpu.reset_n reset

add_connection clk.clk cpu.clk clock

add_connection clk.clk jtag_uart_0.clk clock

add_connection clk.clk_reset jtag_uart_0.reset reset

add_connection cpu.data_master jtag_uart_0.avalon_jtag_slave avalon
set_connection_parameter_value cpu.data_master/jtag_uart_0.avalon_jtag_slave arbitrationPriority {1}
set_connection_parameter_value cpu.data_master/jtag_uart_0.avalon_jtag_slave baseAddress {0x02001008}
set_connection_parameter_value cpu.data_master/jtag_uart_0.avalon_jtag_slave defaultConnection {0}

add_connection cpu.instruction_master jtag_uart_0.avalon_jtag_slave avalon
set_connection_parameter_value cpu.instruction_master/jtag_uart_0.avalon_jtag_slave arbitrationPriority {1}
set_connection_parameter_value cpu.instruction_master/jtag_uart_0.avalon_jtag_slave baseAddress {0x02001008}
set_connection_parameter_value cpu.instruction_master/jtag_uart_0.avalon_jtag_slave defaultConnection {0}

add_connection cpu.d_irq jtag_uart_0.irq interrupt
set_connection_parameter_value cpu.d_irq/jtag_uart_0.irq irqNumber {0}

add_connection clk.clk new_sdram_controller_0.clk clock

add_connection clk.clk_reset new_sdram_controller_0.reset reset

add_connection cpu.data_master new_sdram_controller_0.s1 avalon
set_connection_parameter_value cpu.data_master/new_sdram_controller_0.s1 arbitrationPriority {1}
set_connection_parameter_value cpu.data_master/new_sdram_controller_0.s1 baseAddress {0x01000000}
set_connection_parameter_value cpu.data_master/new_sdram_controller_0.s1 defaultConnection {0}

add_connection cpu.instruction_master new_sdram_controller_0.s1 avalon
set_connection_parameter_value cpu.instruction_master/new_sdram_controller_0.s1 arbitrationPriority {1}
set_connection_parameter_value cpu.instruction_master/new_sdram_controller_0.s1 baseAddress {0x01000000}
set_connection_parameter_value cpu.instruction_master/new_sdram_controller_0.s1 defaultConnection {0}

# exported interfaces
add_interface clk clock sink
set_interface_property clk EXPORT_OF clk.clk_in
add_interface new_sdram_controller_0_wire conduit end
set_interface_property new_sdram_controller_0_wire EXPORT_OF new_sdram_controller_0.wire
