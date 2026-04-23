<script setup lang="ts">
import { ref, watch } from 'vue'
import { Plus, X } from 'lucide-vue-next'
import {
  Dialog,
  DialogClose,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogScrollContent,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { Field, FieldGroup, FieldLabel } from '@/components/ui/field'
import { Button } from '@/components/ui/button'
import { Spinner } from '@/components/ui/spinner'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { Calendar } from '@/components/ui/calendar'
import { putApiPlantsById } from '@/client'
import type { Plant } from '@/client'
import { formatDate } from '@/lib/utils'
import { today, getLocalTimeZone } from '@internationalized/date'
import type { DateValue } from 'reka-ui'
import { toast } from 'vue-sonner'

const props = defineProps<{ plant: Plant }>()
const emit = defineEmits<{ saved: [] }>()

const open = ref(false)
const saving = ref(false)

const sowDates = ref<string[]>([])
const transplantDates = ref<string[]>([])
const repotDates = ref<string[]>([])
const stagingSow = ref<DateValue>()
const stagingTransplant = ref<DateValue>()
const stagingRepot = ref<DateValue>()
const showSowPicker = ref(false)
const showTransplantPicker = ref(false)
const showRepotPicker = ref(false)
const defaultPlaceholder = today(getLocalTimeZone())

watch(open, (isOpen) => {
  if (isOpen) {
    sowDates.value = [...(props.plant.sow_dates ?? [])]
    transplantDates.value = [...(props.plant.transplant_dates ?? [])]
    repotDates.value = [...(props.plant.repot_dates ?? [])]
  }
})

async function save() {
  saving.value = true
  try {
    await putApiPlantsById({
      path: { id: props.plant.id },
      body: {
        plant_type_id: props.plant.plant_type_id ?? '',
        catalogue_id: props.plant.catalogue_id,
        custom_variety: props.plant.custom_variety,
        sow_dates: sowDates.value.length ? sowDates.value : undefined,
        transplant_dates: transplantDates.value.length ? transplantDates.value : undefined,
        repot_dates: repotDates.value.length ? repotDates.value : undefined,
        notes: props.plant.notes,
        year: props.plant.year,
      },
      throwOnError: true,
    })
    emit('saved')
    open.value = false
    toast.success('Dates saved')
  } catch {
    toast.error('Failed to save dates')
  }
  saving.value = false
}
</script>

<template>
  <Dialog v-model:open="open">
    <DialogTrigger as-child>
      <slot />
    </DialogTrigger>

    <DialogScrollContent>
      <DialogHeader>
        <DialogTitle>Add dates</DialogTitle>
        <DialogDescription class="sr-only">Add sow, transplant, or repot dates</DialogDescription>
      </DialogHeader>

      <FieldGroup>
        <Field>
          <FieldLabel>Sow Dates</FieldLabel>
          <div v-if="sowDates.length" class="flex flex-wrap gap-2">
            <span
              v-for="(d, i) in sowDates"
              :key="i"
              class="flex items-center gap-1 rounded-md border px-2 py-1 text-sm"
            >
              {{ formatDate(d) }}
              <button
                type="button"
                class="text-muted-foreground hover:text-foreground"
                @click="sowDates.splice(i, 1)"
              >
                <X class="h-3 w-3" />
              </button>
            </span>
          </div>
          <Popover v-model:open="showSowPicker">
            <PopoverTrigger as-child>
              <Button type="button" variant="outline" size="sm" class="w-full">
                <Plus /> Add sow date
              </Button>
            </PopoverTrigger>
            <PopoverContent class="w-auto p-0">
              <Calendar
                v-model="stagingSow"
                :initial-focus="true"
                :default-placeholder="defaultPlaceholder"
                layout="month-and-year"
                @update:model-value="
                  (v: DateValue | undefined) => {
                    if (!v) return
                    sowDates.push(v.toString())
                    stagingSow = undefined
                    showSowPicker = false
                  }
                "
              />
            </PopoverContent>
          </Popover>
        </Field>

        <Field>
          <FieldLabel>Transplant Dates</FieldLabel>
          <div v-if="transplantDates.length" class="flex flex-wrap gap-2">
            <span
              v-for="(d, i) in transplantDates"
              :key="i"
              class="flex items-center gap-1 rounded-md border px-2 py-1 text-sm"
            >
              {{ formatDate(d) }}
              <button
                type="button"
                class="text-muted-foreground hover:text-foreground"
                @click="transplantDates.splice(i, 1)"
              >
                <X class="h-3 w-3" />
              </button>
            </span>
          </div>
          <Popover v-model:open="showTransplantPicker">
            <PopoverTrigger as-child>
              <Button type="button" variant="outline" size="sm" class="w-full">
                <Plus /> Add transplant date
              </Button>
            </PopoverTrigger>
            <PopoverContent class="w-auto p-0">
              <Calendar
                v-model="stagingTransplant"
                :initial-focus="true"
                :default-placeholder="defaultPlaceholder"
                layout="month-and-year"
                @update:model-value="
                  (v: DateValue | undefined) => {
                    if (!v) return
                    transplantDates.push(v.toString())
                    stagingTransplant = undefined
                    showTransplantPicker = false
                  }
                "
              />
            </PopoverContent>
          </Popover>
        </Field>

        <Field>
          <FieldLabel>Repot Dates</FieldLabel>
          <div v-if="repotDates.length" class="flex flex-wrap gap-2">
            <span
              v-for="(d, i) in repotDates"
              :key="i"
              class="flex items-center gap-1 rounded-md border px-2 py-1 text-sm"
            >
              {{ formatDate(d) }}
              <button
                type="button"
                class="text-muted-foreground hover:text-foreground"
                @click="repotDates.splice(i, 1)"
              >
                <X class="h-3 w-3" />
              </button>
            </span>
          </div>
          <Popover v-model:open="showRepotPicker">
            <PopoverTrigger as-child>
              <Button type="button" variant="outline" size="sm" class="w-full">
                <Plus /> Add repot date
              </Button>
            </PopoverTrigger>
            <PopoverContent class="w-auto p-0">
              <Calendar
                v-model="stagingRepot"
                :initial-focus="true"
                :default-placeholder="defaultPlaceholder"
                layout="month-and-year"
                @update:model-value="
                  (v: DateValue | undefined) => {
                    if (!v) return
                    repotDates.push(v.toString())
                    stagingRepot = undefined
                    showRepotPicker = false
                  }
                "
              />
            </PopoverContent>
          </Popover>
        </Field>
      </FieldGroup>

      <DialogFooter>
        <DialogClose as-child>
          <Button variant="outline">Cancel</Button>
        </DialogClose>
        <Button type="button" :disabled="saving" class="px-4!" @click="save">
          <Spinner v-if="saving" class="animate-spin" />
          {{ saving ? 'Saving...' : 'Save' }}
        </Button>
      </DialogFooter>
    </DialogScrollContent>
  </Dialog>
</template>
