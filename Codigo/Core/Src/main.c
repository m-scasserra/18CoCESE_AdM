/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2022 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "string.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "asm_func.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

ETH_TxPacketConfig TxConfig;
ETH_DMADescTypeDef  DMARxDscrTab[ETH_RX_DESC_CNT]; /* Ethernet Rx DMA Descriptors */
ETH_DMADescTypeDef  DMATxDscrTab[ETH_TX_DESC_CNT]; /* Ethernet Tx DMA Descriptors */

 ETH_HandleTypeDef heth;

UART_HandleTypeDef huart3;

PCD_HandleTypeDef hpcd_USB_OTG_FS;

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_ETH_Init(void);
static void MX_USART3_UART_Init(void);
static void MX_USB_OTG_FS_PCD_Init(void);
void zeros(uint32_t *vector, uint32_t longitud);
void productoEscalar32(uint32_t *vectorIn, uint32_t *vectorOut, uint32_t longitud, uint32_t escalar);
void productoEscalar16(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitud, uint16_t escalar);
void productoEscalar12(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitud, uint16_t escalar);
void filtroVentana10(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitudVectorIn);
void pack32to16(int32_t *vectorIn, int16_t *vectorOut, uint32_t longitud);
uint32_t max(int32_t *vectorIn, uint32_t longitud);
void downsampleM(int32_t *vectorIn, int32_t *vectorOut, uint32_t longitud, uint32_t N);
void invertir(uint16_t *vector, uint32_t longitud);
void eco(int16_t *vectorIn, int16_t *vectorOut, uint32_t longitud);

/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
int __io_putchar (int ch)
{
    HAL_UART_Transmit (&huart3, (uint8_t *)&ch, 1, HAL_MAX_DELAY);
    return ch;
}

static void PrivilegiosSVC (void)
{
    // Obtiene valor del registro de 32 bits del procesador llamado "control".
    // El registro guarda los siguientes estados:
    // bit 2: Uso de FPU en el contexto actual. Usado=1, no usado=0.
    // bit 1: Mapeo del stack pointer(sp). MSP=0, PSP=1.
    // bit 0: Modo de ejecucion en Thread. Privilegiado=0, No privilegiado=1.
    //        Recordar que este valor solo se usa en modo Thread. Las
    //        interrupciones siempre se ejecutan en modo Handler con total
    //        privilegio.
    uint32_t x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    //__BKPT (0);

    x |= 1;
    // bit 0 a modo No privilegiado.
    __set_CONTROL (x);

    // En este punto se estaria ejecutando en modo No privilegiado.
    // Lectura del registro "control" para confirmar.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    //__BKPT (0);

    x &= ~1u;
    // Se intenta volver a modo Privilegiado (bit 0, valor 0).
    __set_CONTROL (x);

    // Confirma que esta operacion es ignorada por estar ejecutandose en modo
    // Thread no privilegiado.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    //__BKPT (0);

    // En este punto, ejecutando en modo Thread no privilegiado, la unica forma
    // de volver a modo privilegiado o de realizar cualquier cambio que requiera
    // modo privilegiado, es pidiendo ese servicio a un hipotetico sistema
    // opertivo de tiempo real.
    // Para esto se invoca por software a la interrupcion SVC (Supervisor Call)
    // utilizando la instruccion "svc".
    // No hay intrinsics para realizar esta tarea. Para utilizar la instruccion
    // es necesario implementar una funcion en assembler. Ver el archivo
    // asm_func.S.
    asm_svc ();

    // El sistema operativo (el handler de SVC) deberia haber devuelto el modo
    // de ejecucion de Thread a privilegiado (bit 0 en valor 0).
    x = __get_CONTROL ();

    // Fin del ejemplo de SVC
}
/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  // Activa contador de ciclos (iniciar una sola vez)
  DWT->CTRL |= 1 << DWT_CTRL_CYCCNTENA_Pos;
  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_ETH_Init();
  MX_USART3_UART_Init();
  MX_USB_OTG_FS_PCD_Init();
  /* USER CODE BEGIN 2 */
  PrivilegiosSVC ();

  const uint32_t Resultado = asm_sum (5, 3);

  int16_t vectorEcoin[4096] = {0};
  int16_t vectorEcoout[4096] = {0};
  vectorEcoin[0] = 10;
  vectorEcoin[1] = -10;
  vectorEcoin[881] = 77;
  vectorEcoin[882] = 100;
  vectorEcoin[883] = 100;
  vectorEcoin[4095] = 40;
  vectorEcoin[3213] = 20;

  uint16_t vectMultIn[3] = {0, 1, 2};
  uint16_t vectMultOut[3] = {0, 0, 0};

  int32_t vectPack[2] = {0xFFF0000, 0x000FFFF};
  int16_t vectUnpack[2] = {0, 0};

  uint16_t vectIn[20] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19};
  int32_t vectIn2[20] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19};

  uint16_t vectOut[20] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};


  DWT->CYCCNT = 0;
  asm_productoEscalar12(vectMultIn, vectMultOut, 3, 3000);
  const volatile uint32_t CiclosAsmEscalar12 = DWT->CYCCNT;

  DWT->CYCCNT = 0;
  productoEscalar12(vectMultIn, vectMultOut, 3, 3000);
  const volatile uint32_t CiclosCEscalar12 = DWT->CYCCNT;

  DWT->CYCCNT = 0;
  asm_filtroVentana10(vectIn, vectOut, 20);
  const volatile uint32_t CiclosAsmFiltro= DWT->CYCCNT;

  DWT->CYCCNT = 0;
  filtroVentana10(vectIn, vectOut, 20);
  const volatile uint32_t CiclosCFiltro= DWT->CYCCNT;

  asm_pack32to16(vectPack, vectUnpack, 2);

  uint32_t maximoresultado = 0;
  maximoresultado = asm_max(vectIn2, 20);
  int32_t downsamplevect[16] = {0};
  downsampleM(vectIn2, downsamplevect, 20, 5);
  asm_invertir(vectIn, 20);

  DWT->CYCCNT = 0;
  asm_eco(vectorEcoin, vectorEcoout, 4096);
  const volatile uint32_t CiclosAsmEco = DWT->CYCCNT;

  DWT->CYCCNT = 0;
  eco(vectorEcoin, vectorEcoout, 4096);
  const volatile uint32_t CiclosCEco = DWT->CYCCNT;

  printf("La funcion de saturacion a 12 bits tarda en C %d ciclos y en ASM %d ciclos.\n\r", CiclosCEscalar12, CiclosAsmEscalar12);
  printf("La funcion de filtro de ventana tarda en C %d ciclos y en ASM %d ciclos.\n\r", CiclosCFiltro, CiclosAsmFiltro);
  printf("La funcion de eco tarda en C %d ciclos y en ASM %d ciclos.\n\r", CiclosCEco, CiclosAsmEco);

  vectIn[1] = 1;

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_BYPASS;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 4;
  RCC_OscInitStruct.PLL.PLLN = 168;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 7;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief ETH Initialization Function
  * @param None
  * @retval None
  */
static void MX_ETH_Init(void)
{

  /* USER CODE BEGIN ETH_Init 0 */

  /* USER CODE END ETH_Init 0 */

   static uint8_t MACAddr[6];

  /* USER CODE BEGIN ETH_Init 1 */

  /* USER CODE END ETH_Init 1 */
  heth.Instance = ETH;
  MACAddr[0] = 0x00;
  MACAddr[1] = 0x80;
  MACAddr[2] = 0xE1;
  MACAddr[3] = 0x00;
  MACAddr[4] = 0x00;
  MACAddr[5] = 0x00;
  heth.Init.MACAddr = &MACAddr[0];
  heth.Init.MediaInterface = HAL_ETH_RMII_MODE;
  heth.Init.TxDesc = DMATxDscrTab;
  heth.Init.RxDesc = DMARxDscrTab;
  heth.Init.RxBuffLen = 1524;

  /* USER CODE BEGIN MACADDRESS */

  /* USER CODE END MACADDRESS */

  if (HAL_ETH_Init(&heth) != HAL_OK)
  {
    Error_Handler();
  }

  memset(&TxConfig, 0 , sizeof(ETH_TxPacketConfig));
  TxConfig.Attributes = ETH_TX_PACKETS_FEATURES_CSUM | ETH_TX_PACKETS_FEATURES_CRCPAD;
  TxConfig.ChecksumCtrl = ETH_CHECKSUM_IPHDR_PAYLOAD_INSERT_PHDR_CALC;
  TxConfig.CRCPadCtrl = ETH_CRC_PAD_INSERT;
  /* USER CODE BEGIN ETH_Init 2 */

  /* USER CODE END ETH_Init 2 */

}

/**
  * @brief USART3 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART3_UART_Init(void)
{

  /* USER CODE BEGIN USART3_Init 0 */

  /* USER CODE END USART3_Init 0 */

  /* USER CODE BEGIN USART3_Init 1 */

  /* USER CODE END USART3_Init 1 */
  huart3.Instance = USART3;
  huart3.Init.BaudRate = 115200;
  huart3.Init.WordLength = UART_WORDLENGTH_8B;
  huart3.Init.StopBits = UART_STOPBITS_1;
  huart3.Init.Parity = UART_PARITY_NONE;
  huart3.Init.Mode = UART_MODE_TX_RX;
  huart3.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart3.Init.OverSampling = UART_OVERSAMPLING_16;
  if (HAL_UART_Init(&huart3) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART3_Init 2 */

  /* USER CODE END USART3_Init 2 */

}

/**
  * @brief USB_OTG_FS Initialization Function
  * @param None
  * @retval None
  */
static void MX_USB_OTG_FS_PCD_Init(void)
{

  /* USER CODE BEGIN USB_OTG_FS_Init 0 */

  /* USER CODE END USB_OTG_FS_Init 0 */

  /* USER CODE BEGIN USB_OTG_FS_Init 1 */

  /* USER CODE END USB_OTG_FS_Init 1 */
  hpcd_USB_OTG_FS.Instance = USB_OTG_FS;
  hpcd_USB_OTG_FS.Init.dev_endpoints = 4;
  hpcd_USB_OTG_FS.Init.speed = PCD_SPEED_FULL;
  hpcd_USB_OTG_FS.Init.dma_enable = DISABLE;
  hpcd_USB_OTG_FS.Init.phy_itface = PCD_PHY_EMBEDDED;
  hpcd_USB_OTG_FS.Init.Sof_enable = ENABLE;
  hpcd_USB_OTG_FS.Init.low_power_enable = DISABLE;
  hpcd_USB_OTG_FS.Init.lpm_enable = DISABLE;
  hpcd_USB_OTG_FS.Init.vbus_sensing_enable = ENABLE;
  hpcd_USB_OTG_FS.Init.use_dedicated_ep1 = DISABLE;
  if (HAL_PCD_Init(&hpcd_USB_OTG_FS) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USB_OTG_FS_Init 2 */

  /* USER CODE END USB_OTG_FS_Init 2 */

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOG_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOB, LD1_Pin|LD3_Pin|LD2_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(USB_PowerSwitchOn_GPIO_Port, USB_PowerSwitchOn_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin : USER_Btn_Pin */
  GPIO_InitStruct.Pin = USER_Btn_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(USER_Btn_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pins : LD1_Pin LD3_Pin LD2_Pin */
  GPIO_InitStruct.Pin = LD1_Pin|LD3_Pin|LD2_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pin : USB_PowerSwitchOn_Pin */
  GPIO_InitStruct.Pin = USB_PowerSwitchOn_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(USB_PowerSwitchOn_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pin : USB_OverCurrent_Pin */
  GPIO_InitStruct.Pin = USB_OverCurrent_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(USB_OverCurrent_GPIO_Port, &GPIO_InitStruct);

}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}
/**
  * @brief  Esta funcion toma el puntero de un vector y su longitud, y pone
  *         sus valores en 0.
  * @retval None
  */
void zeros(uint32_t *vector, uint32_t longitud)
{
    /* USER CODE BEGIN zeros*/
    for(uint32_t i = 0; i < longitud; i++)
    {
        vector[i] = 0;
    }
    /* USER CODE END zeros*/
}

/**
  * @brief  Esta funcion toma el puntero de un vector de entrada, el puntero de
            un vector de salida, la longitud y un escalar y multiplica cada uno
            de los valores del vector de entrada por el escalar y los guarda
            en la respectiva posicion del vector de salida.
  * @retval None
  */
void productoEscalar32(uint32_t *vectorIn, uint32_t *vectorOut, uint32_t longitud, uint32_t escalar)
{
    /* USER CODE BEGIN productoEscalar32*/
    for(uint32_t i = 0; i < longitud; i++)
    {
        vectorOut[i] = vectorIn[i] * escalar;
    }
    /* USER CODE END productoEscalar32*/
}

/**
  * @brief  Esta funcion toma el puntero de un vector de entrada, el puntero de
            un vector de salida, la longitud y un escalar y multiplica cada uno
            de los valores del vector de entrada por el escalar y los guarda
            en la respectiva posicion del vector de salida.
  * @retval None
  */
void productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar)
{
    /* USER CODE BEGIN productoEscalar32*/
    for(uint32_t i = 0; i < longitud; i++)
    {
        vectorOut[i] = vectorIn[i] * escalar;
    }
    /* USER CODE END productoEscalar32*/
}

/**
  * @brief  Esta funcion toma el puntero de un vector de entrada, el puntero de
            un vector de salida, la longitud y un escalar y multiplica cada uno
            de los valores del vector de entrada por el escalar y los guarda
            en la respectiva posicion del vector de salida. Si el resultado es
            mayor a 12 bits entonces satura el resultado.
  * @retval None
  */
void productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar)
{
    /* USER CODE BEGIN productoEscalar32*/
    for(uint32_t i = 0; i < longitud; i++)
    {
        if((uint32_t)(vectorIn[i] * escalar) > 4095)
        {
        	vectorOut[i] = 4095;
        }else
        {
        	vectorOut[i] = vectorIn[i] * escalar;
        }
    }
    /* USER CODE END productoEscalar32*/
}

/**
  * @brief  Esta funcion toma el puntero de un vector de entrada, el puntero de
            un vector de salida, la longitud y un escalar y multiplica cada uno
            de los valores del vector de entrada por el escalar y los guarda
            en la respectiva posicion del vector de salida. Si el resultado es
            mayor a 12 bits entonces satura el resultado.
  * @retval None
  */
void filtroVentana10(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitudVectorIn)
{
	/* USER CODE BEGIN filtroVentana10*/
	uint32_t sumaTemp = 0;
	for(uint32_t indVectOut = 0; indVectOut < longitudVectorIn; indVectOut ++)
	{
		sumaTemp = 0;
		for(uint32_t numInd = 1; numInd < 6; numInd ++)
		{
			if(!((int32_t)(indVectOut - numInd) < 0))
			{
				sumaTemp = sumaTemp + vectorIn[indVectOut - numInd];
			}

			if(!((int32_t)(indVectOut + numInd) > longitudVectorIn))
			{
				sumaTemp = sumaTemp + vectorIn[indVectOut + numInd];
			}
		}
		sumaTemp = sumaTemp + vectorIn[indVectOut];
		vectorOut[indVectOut] = sumaTemp / 11;
	}
	/* USER CODE END filtroVentana10*/
}

/**
  * @brief  Esta funcion toma el puntero de un vector de entrada, el puntero de
            un vector de salida y la longitud y empaqueta cada valor de 32 bits
            del vector de entrada en los 16 bits del vector de salida,
            efectivamente removiendo presicion del valor.
  * @retval None
  */
void pack32to16(int32_t *vectorIn, int16_t *vectorOut, uint32_t longitud)
{
	/* USER CODE BEGIN pack32to16*/
	for(uint32_t i = 0; i < longitud; i++)
	{
		vectorOut[i] = vectorIn[i] >> 16;
	}
	/* USER CODE END pack32to16*/
}

/**
  * @brief  Esta funcion toma el puntero de un vector de entrada y la longitud
  * 		y devuelve la posicion del elemento mas grande.
  * @retval uint32_t posMax siendo la posicion en el vector del elemento mas grande
  */
uint32_t max(int32_t *vectorIn, uint32_t longitud)
{
	/* USER CODE BEGIN max*/
	uint32_t valorMax = vectorIn[0];
	uint32_t posMax = 0;
	if(longitud > 1)
	{
		for(uint32_t i = 1; i < longitud; i++)
		{
			if(vectorIn[i] > valorMax)
			{
				valorMax = vectorIn[i];
				posMax = i;
			}
		}
	}
	return posMax;
	/* USER CODE END max*/
}

/**
  * @brief  Esta funcion toma el puntero de un vector de entrada, el puntero
  * 		de un vector de salida, la longitud y un entero N. Copia los valores
  * 		del vector de entrada en el vector de salida descartando 1 cada N
  * 		valores.
  * @retval None
  */
void downsampleM(int32_t *vectorIn, int32_t *vectorOut, uint32_t longitud, uint32_t N)
{
	/* USER CODE BEGIN downsampleM*/
	uint32_t contador = 1;
	uint32_t indiceSalida = 0;
	for(uint32_t i = 0; i < longitud; i++)
	{
		if(contador < N)
		{
			vectorOut[indiceSalida] = vectorIn[i];
			indiceSalida = indiceSalida + 1;
			contador = contador + 1;
		}else
		{
			contador = 1;
		}
	}
	/* USER CODE END downsampleM*/
}

/**
  * @brief  Esta funcion toma el puntero de un vector de entrada y la longitud
  * 		e invierte el orden de los valores.
  * @retval None
  */
void invertir(uint16_t *vector, uint32_t longitud)
{
	/* USER CODE BEGIN invertir*/
	uint16_t auxBot = 0;
	uint16_t auxTop = 0;
	for(uint32_t i = 0; i < (longitud >> 1); i++)
	{
		auxBot = vector[i];
		auxTop = vector[longitud - 1 - i];
		vector[i] = auxTop;
		vector[longitud - 1 - i] = auxBot;
	}
	/* USER CODE END invertir*/
}

/**
  * @brief  Esta funcion toma el puntero de un vector de entrada el puntero a
  * 		un vector de salida y su longitud e introduce un eco de la mitad
  * 		de un valor con un offset de 882 posiciones en el vector de salida.
  * @retval None
  */
void eco(int16_t *vectorIn, int16_t *vectorOut, uint32_t longitud)
{
	for(uint16_t i = 0; i < 882; i++)
	{
		vectorOut[i] = vectorIn[i];
	}
	for(uint16_t i = 882; i < longitud; i ++)
	{
		vectorOut[i] = vectorIn[i] + (vectorIn[i - 882] / 2);
	}
}


#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
