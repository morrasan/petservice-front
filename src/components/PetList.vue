<script setup>
import PetItem from '@/components/PetItem.vue'
import { ref, onBeforeMount, onBeforeUnmount, watch } from 'vue'
import axios from "axios";

const cursor = ref(0)

const items = ref([])

const petStatuses = ref(['available'])

const statuses = ref([
  'available',
  'pending',
  'sold',
])

watch(petStatuses, statuses => {

  if (statuses.length) {

    api(0)
  }
})

const url = import.meta.env.VITE_API_URL

// set listener for fetch new uploaded items
onBeforeMount(() => {
  document.addEventListener('fetchData', refreshData)
})

onBeforeUnmount(() => {
  document.removeEventListener('fetchData', refreshData)
})

// refresh pets
const refreshData = () => {
  cursor.value = 0
  api(0)
}

// fetch pets from back
const api =  async (currentCursor) => {
  return new Promise((resolve) => {
    axios.get(url + '/api/pet/find-by-status', {
      params: {
        cursor: currentCursor,
        statuses: petStatuses.value
      },
      headers: {
        'Accept': 'application/json'
      }
    }).then(result => {

      if (result.data.data instanceof Array && result.data.nextCursor) {

        // add received files to the list
        if (currentCursor) {

          items.value.push(...result.data.data)

        } else {

          items.value = result.data.data
        }


        // set cursor on the last item
        cursor.value = result.data.nextCursor

        resolve('ok')
      } else {

        if (!currentCursor) {

          items.value = []
        }

        resolve('empty')
      }

    }).catch(error => {

      console.error('ERROR:', error)
      resolve('error')
    })
  })
}


const fetchDataByCursor = async ({ done }) => {

  const res = await api(cursor.value)

  done(res)
}
</script>

<template>
  <h3 class="text-center mb-3">Pet list</h3>
  <v-select
    v-model="petStatuses"
    :items="statuses"
    label="Statuses"
    chips
    multiple
    variant="outlined"
    clearable
    rounded
  ></v-select>
  <v-infinite-scroll
    :height="1050"
    :items="items"
    @load="fetchDataByCursor"
  >
    <template v-for="(item, index) in items" :key="item">
      <div :class="['pa-6', index % 2 === 0 ? 'bg-grey-lighten-2' : '']">
        <PetItem :item="item"></PetItem>
      </div>
    </template>
  </v-infinite-scroll>
</template>

<style scoped>
.long-word {
  word-break: break-all;
}
.v-alert {
  border-radius: 24px;
}
</style>
